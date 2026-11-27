-- src/gamepad.lua
-- Joystick input mapping. LÖVE exposes joysticks as 1-based indices.

local gamepad = {}

gamepad.actions = { "left", "right", "dash", "focus", "pause", "mute" }

function gamepad.read()
  local result = {}
  if not (love and love.joystick and love.joystick.getJoysticks) then
    return result
  end
  local sticks = love.joystick.getJoysticks()
  local pad = sticks[1]
  if not pad then
    return result
  end
  local ax = pad:getAxis(1) or 0
  if ax < -0.3 then
    result.left = true
  end
  if ax > 0.3 then
    result.right = true
  end
  if pad:isGamepad() then
    if pad:isGamepadDown("leftshoulder") then
      result.dash = true
    end
    if pad:isGamepadDown("a") then
      result.focus = true
    end
    if pad:isGamepadDown("start") then
      result.pause = true
    end
    if pad:isGamepadDown("b") then
      result.mute = true
    end
  end
  return result
end

function gamepad.connected()
  if not (love and love.joystick) then
    return 0
  end
  return love.joystick.getJoystickCount()
end

return gamepad
