-- ---------------------------------------------------------------
-- audio-toggle.lua
--
-- Toggle audio output between headphones and speakers.
-- Hotkey: Shift + Page Up
--
-- Fading lives in audio-fade.lua. Set ENABLE_FADE to false below to
-- turn it off; the switch then happens instantly and no volume is
-- touched at all.
-- ---------------------------------------------------------------

local ENABLE_FADE = true

local HEADPHONES = "External Headphones"
local SPEAKERS   = "MacBook Pro Speakers"

-- When disabled, require() is never evaluated, so audio-fade.lua
-- can be deleted outright.
local fade = ENABLE_FADE and require("audio-fade") or nil

-- Stand-in used when fading is off. Every call is a no-op, and ramp
-- still invokes its callback so the flow below is identical either way.
local NO_FADE = {
  ramp     = function(_, _, _, done) if done then done() end end,
  volumeOf = function() return nil end,
  silence  = function() return nil end,
  restore  = function() end,
}

local fx = fade or NO_FADE

local busy = false

local function matches(name, fragment)
  if not name then return false end
  return name:lower():find(fragment:lower(), 1, true) ~= nil
end

local function findOutputs(fragment)
  local found = {}
  for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
    if matches(dev:name(), fragment) then
      table.insert(found, dev)
    end
  end
  return found
end

local ALERT_SECONDS = 1.2
local ALERT_STYLE = {
  textSize        = 24,
  textColor       = { white = 1, alpha = 1 },
  fillColor       = { white = 0, alpha = 0.75 },
  strokeWidth     = 0,
  radius          = 10,
  padding         = 16,
  fadeInDuration  = 0.10,
  fadeOutDuration = 0.25,
}

local function notify(text)
  -- Clear any alert still on screen so rapid switches don't stack.
  hs.alert.closeAll(0)
  hs.alert.show(text, ALERT_STYLE, hs.screen.mainScreen(), ALERT_SECONDS)
end

-- Walk the candidates and return the first one that actually becomes
-- the default output, along with the level it should end up at.
-- Anything it silences but doesn't use is put back.
local function switchTo(candidates, currentUid)
  for _, dev in ipairs(candidates) do
    -- Silence the incoming device before it becomes default, or it
    -- blares for a moment at its stored level.
    local vol = fx.silence(dev)

    dev:setDefaultOutputDevice()
    dev:setDefaultEffectDevice()

    local now = hs.audiodevice.defaultOutputDevice()
    if now and now:uid() ~= currentUid then
      return dev, vol
    end

    fx.restore(dev, vol)
    print("[audio-toggle] no-op on:", dev:name(), dev:uid())
  end
  return nil, nil
end

local function toggleOutput()
  if busy then return end   -- ignore repeat presses mid-fade

  local current     = hs.audiodevice.defaultOutputDevice()
  local currentUid  = current and current:uid()
  local currentName = current and current:name() or "(none)"
  local currentVol  = fx.volumeOf(current)

  local wantFragment = matches(currentName, HEADPHONES) and SPEAKERS or HEADPHONES
  local candidates = findOutputs(wantFragment)

  if #candidates == 0 then
    notify("No device matching \"" .. wantFragment .. "\"")
    print("[audio-toggle] no match for:", wantFragment)
    return
  end

  busy = true

  fx.ramp(current, currentVol or 0, 0, function()
    local switched, targetVol = switchTo(candidates, currentUid)

    -- Put the device we left back to its own level, so it's correct
    -- when we switch back to it later.
    fx.restore(current, currentVol)

    if switched then
      notify(switched:name())
      print("[audio-toggle] switched:", currentName, "->", switched:name())
      fx.ramp(switched, 0, targetVol or 0, function() busy = false end)
    else
      busy = false
      notify("Could not switch to " .. wantFragment)
    end
  end)
end

hs.hotkey.bind({"shift"}, "pageup", toggleOutput)
