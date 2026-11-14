-- src/player.lua
-- The yellow sticky note: a 40x40 box sliding along the bottom of the arena.

local player = {}

player.w = 40
player.h = 40
player.base_speed = 400 -- px/s

function player.reset()
  player.x = (800 - player.w) / 2
  player.y = 600 - player.h - 24
  player.dir = 1 -- control multiplier, KONTROL TERBALIK flips it
  player.speed = player.base_speed
  player.always_move = false -- TIDAK BISA BERHENTI
  player.last_dir = 1
end

-- `left`/`right` are booleans, `speed_mul` comes from the world so
-- SEMUA 2X CEPAT also accelerates the player.
function player.update(dt, left, right, speed_mul)
  local move = 0
  if left then
    move = move - 1
  end
  if right then
    move = move + 1
  end
  move = move * player.dir

  if player.always_move then
    if move ~= 0 then
      player.last_dir = move > 0 and 1 or -1
    end
    move = player.last_dir
  end

  player.x = player.x + move * player.speed * (speed_mul or 1) * dt
  if player.x < 0 then
    player.x = 0
  end
  if player.x > 800 - player.w then
    player.x = 800 - player.w
  end
end

function player.draw()
  local x, y, w, h = player.x, player.y, player.w, player.h

  -- Drop shadow
  love.graphics.setColor(0, 0, 0, 0.35)
  love.graphics.rectangle("fill", x + 4, y + 4, w, h, 6, 6)

  -- Body (brand yellow)
  love.graphics.setColor(1.000, 0.824, 0.247, 1)
  love.graphics.rectangle("fill", x, y, w, h, 6, 6)

  -- Inner highlight, sticky-note style
  love.graphics.setColor(1.000, 0.925, 0.455, 1)
  love.graphics.rectangle("fill", x + 5, y + 5, w - 10, h * 0.38, 4, 4)

  -- Outline
  love.graphics.setColor(0.35, 0.26, 0.05, 0.9)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, w, h, 6, 6)
  love.graphics.setLineWidth(1)

  love.graphics.setColor(1, 1, 1, 1)
end

return player
