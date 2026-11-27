-- src/transition.lua
-- Screen wipe transition using a thin cyan line and a fade.

local transition = {}

transition.active = false
transition.phase = "out" -- "out" | "in"
transition.t = 0
transition.duration = 0.32
transition.action = nil

function transition.start(action, duration)
  transition.active = true
  transition.phase = "out"
  transition.t = 0
  transition.duration = duration or 0.32
  transition.action = action
end

function transition.update(dt)
  if not transition.active then
    return
  end
  transition.t = transition.t + dt
  if transition.t >= transition.duration then
    if transition.phase == "out" then
      if transition.action then
        transition.action()
      end
      transition.action = nil
      transition.phase = "in"
      transition.t = 0
    else
      transition.active = false
    end
  end
end

function transition.draw()
  if not transition.active then
    return
  end
  local p = math.min(1, transition.t / transition.duration)
  local cover = transition.phase == "out" and p or (1 - p)
  love.graphics.setColor(0.01, 0.012, 0.02, cover)
  love.graphics.rectangle("fill", 0, 0, 800, 600)
  love.graphics.setColor(0.122, 0.780, 0.937, 1)
  local line_y = 300 + (transition.phase == "out" and -1 or 1) * p * 300
  love.graphics.rectangle("fill", 0, line_y - 2, 800, 4)
  love.graphics.setColor(1, 1, 1, 1)
end

return transition
