-- ---------------------------------------------------------------
-- audio-fade.lua
--
-- Optional volume fading for audio-toggle.lua.
-- Nothing else depends on this file; deleting it is safe as long as
-- ENABLE_FADE is false in audio-toggle.lua.
-- ---------------------------------------------------------------

local M = {}

M.FADE_MS = 180   -- total fade time each way
M.STEPS   = 12    -- resolution of the ramp
M.CURVE   = 2     -- 1 = linear, higher = more time spent quiet

-- Module-level so the running timer isn't garbage collected mid-fade.
local activeTimer = nil

-- Devices that don't expose software volume control return nil here
-- (HDMI, some USB DACs). Callers treat nil as "can't fade this".
function M.volumeOf(dev)
  if not dev then return nil end
  return dev:outputVolume()
end

-- Drop a device to silence, returning its previous level so the
-- caller can put it back.
function M.silence(dev)
  local vol = M.volumeOf(dev)
  if vol then dev:setOutputVolume(0) end
  return vol
end

function M.restore(dev, vol)
  if dev and vol then dev:setOutputVolume(vol) end
end

function M.cancel()
  if activeTimer then
    activeTimer:stop()
    activeTimer = nil
  end
end

-- Ramp a device between two volumes, then call done().
-- Always calls done(), including when it can't fade.
function M.ramp(dev, fromVol, toVol, done)
  if not dev or M.volumeOf(dev) == nil or fromVol == toVol then
    if done then done() end
    return
  end

  M.cancel()

  local step = 0
  local rising = toVol > fromVol

  activeTimer = hs.timer.doEvery(M.FADE_MS / 1000 / M.STEPS, function()
    step = step + 1
    local t = step / M.STEPS

    -- Ease so both directions linger in the quiet part of the range.
    local eased
    if rising then
      eased = t ^ M.CURVE
    else
      eased = 1 - (1 - t) ^ M.CURVE
    end

    if step >= M.STEPS then
      M.cancel()
      dev:setOutputVolume(toVol)
      if done then done() end
    else
      dev:setOutputVolume(fromVol + (toVol - fromVol) * eased)
    end
  end)
end

return M
