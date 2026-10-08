-- ---------------------------------------------------------------
-- emoji-shift.lua
--
-- Double-tap Shift (either side) to open the emoji picker.
-- Fires on the second release, so Shift isn't held when the
-- picker's own shortcut (Ctrl + Cmd + Space) is sent. Any other key
-- or modifier in between cancels it, so normal typing never triggers.
-- ---------------------------------------------------------------

local DOUBLE_TAP_WINDOW = 0.35   -- seconds allowed between taps

local state = { lastTap = 0, pressed = false, interrupted = false }

local function onFlags(e)
  local f = e:getFlags()
  local onlyShift = f.shift and not (f.cmd or f.alt or f.ctrl)

  if onlyShift and not state.pressed then
    state.pressed = true
    state.interrupted = false
  elseif not f.shift and state.pressed then
    state.pressed = false
    if state.interrupted then
      state.lastTap = 0
    else
      local now = hs.timer.secondsSinceEpoch()
      if now - state.lastTap < DOUBLE_TAP_WINDOW then
        state.lastTap = 0
        hs.eventtap.keyStroke({ "ctrl", "cmd" }, "space")
      else
        state.lastTap = now
      end
    end
  else
    state.interrupted = true
  end
  return false
end

-- A real key press (e.g. Shift + A) cancels the double-tap.
local function onKey()
  state.interrupted = true
  state.lastTap = 0
  return false
end

local types = hs.eventtap.event.types

-- Returned so require() keeps them referenced in package.loaded;
-- otherwise Lua garbage-collects the watchers and they stop firing.
return {
  flags = hs.eventtap.new({ types.flagsChanged }, onFlags):start(),
  keys  = hs.eventtap.new({ types.keyDown }, onKey):start(),
}
