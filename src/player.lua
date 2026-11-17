-- src/player.lua
-- The yellow sticky note: a 40x40 box sliding along the bottom of the arena.
-- Drawn with squash and stretch, eyes that look where it moves, and a soft halo.

local theme = require("src.theme")

local player = {}

player.w = 40
player.h = 40
player.base_speed = 400 -- px/s

function player.reset()
  player.w = 40
  player.h = 40
  player.x = (800 - player.w) / 2
  player.y = 600 - player.h - 24
  player.dir = 1 -- control multiplier, KONTROL TERBALIK flips it
  player.speed = player.base_speed
  player.always_move = false -- TIDAK BISA BERHENTI
  player.last_dir = 1
  player.look = 1 -- -1 left, 1 right, drives the pupils
  player.impact = 0 -- squash and stretch trigger, 1 -> 0
  player.bob = 0 -- idle animation clock
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

  if move ~= 0 then
    player.look = move > 0 and 1 or -1
  end

  player.x = player.x + move * player.speed * (speed_mul or 1) * dt
  if player.x < 0 then
    player.x = 0
  end
  if player.x > 800 - player.w then
    player.x = 800 - player.w
  end

  player.impact = math.max(0, player.impact - dt * 2.6)
  player.bob = player.bob + dt * 3.1
end

function player.draw()
  local x, y, w, h = player.x, player.y, player.w, player.h
  local cx, cy = x + w / 2, y + h
  local imp = player.impact
  local sx, sy = 1 + imp * 0.28, 1 - imp * 0.24
  local bob = math.sin(player.bob) * 1.6

  -- Soft halo under the note (additive, does not tint the body)
  love.graphics.setBlendMode("add")
  love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 0.16 + 0.1 * imp)
  love.graphics.circle("fill", cx, y + h / 2, 30 + 4 * imp)
  love.graphics.setBlendMode("alpha")

  -- Drop shadow, planted on the ground line
  love.graphics.setColor(0, 0, 0, 0.35)
  love.graphics.ellipse("fill", cx, y + h + 6, w * 0.62 - 2 * imp, 7 - 3 * imp)

  love.graphics.push()
  love.graphics.translate(cx, cy)
  love.graphics.scale(sx, sy)
  love.graphics.translate(0, bob / sy)
  love.graphics.translate(-cx, -cy)

  -- Body (brand yellow)
  love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
  love.graphics.rectangle("fill", x, y, w, h, 6, 6)

  -- Inner highlight, sticky-note style
  love.graphics.setColor(theme.yellow_hi[1], theme.yellow_hi[2], theme.yellow_hi[3], 1)
  love.graphics.rectangle("fill", x + 5, y + 5, w - 10, h * 0.36, 4, 4)

  -- Outline
  love.graphics.setColor(0.35, 0.26, 0.05, 0.9)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, w, h, 6, 6)
  love.graphics.setLineWidth(1)

  -- Eyes: two rounded eyes tracking the direction of travel
  local eye_y = y + h * 0.55
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle("fill", x + 7.5, eye_y - 5, 11, 10, 4, 4)
  love.graphics.rectangle("fill", x + w - 18.5, eye_y - 5, 11, 10, 4, 4)
  local pupil_offset = 2.1 * player.look
  love.graphics.setColor(0.14, 0.10, 0.04, 1)
  love.graphics.circle("fill", x + 13 + pupil_offset, eye_y + 0.5, 2.4)
  love.graphics.circle("fill", x + w - 13 + pupil_offset, eye_y + 0.5, 2.4)

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
end

return player
