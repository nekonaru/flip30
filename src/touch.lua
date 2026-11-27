-- src/touch.lua
-- Simple touch zones for mobile: left half, right half, centre tap.

local touch = {}

function touch.read(x, y)
  if not x or not y then
    return {}
  end
  if x < 260 and y > 350 then
    return { left = true }
  end
  if x > 540 and y > 350 then
    return { right = true }
  end
  return { focus = true }
end

function touch.available()
  if not (love and love.touch) then
    return false
  end
  return love.touch.getTouchCount() > 0
end

return touch
