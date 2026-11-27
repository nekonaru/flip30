-- src/hazards.lua
-- Arena hazards: laser sweeps, shrinking arena and blackout.

local hazards = {}

local function new_state()
  return { laser = 0, laser_x = 200, shrink = 1, blackout = 0, t = 0 }
end

function hazards.reset(h)
  h.laser, h.shrink, h.blackout, h.t = 0, 1, 0, 0
end

function hazards.update(h, dt, elapsed)
  h.t = h.t + dt
  if elapsed >= 30 then
    h.laser = (h.laser + dt) % 6
    h.laser_x = 100 + 600 * (0.5 + 0.5 * math.sin(h.t * 0.8))
  end
  if elapsed >= 90 then
    h.shrink = math.max(0.6, 1 - (elapsed - 90) / 600)
  end
  if elapsed >= 150 and math.floor(h.t) % 20 == 0 then
    h.blackout = 3
  end
  h.blackout = math.max(0, h.blackout - dt)
end

function hazards.hits_player(h, player)
  if h.laser <= 0.6 then
    return false
  end
  return math.abs(player.x + player.w / 2 - h.laser_x) < 16
end

hazards.new_state = new_state

return hazards
