-- src/spawner.lua
-- Spawns and moves objects: food, gold, enemy variants and pickups.
-- TUKAR WARNA only repaints food and enemies; shape and behaviour follow kind.

local world = require("src.world")
local theme = require("src.theme")
local enemies = require("src.enemies")
local pickups = require("src.pickups")
local rng = require("src.rng")

local spawner = {}

spawner.FOOD = "food"
spawner.ENEMY = "enemy"
spawner.GOLD = "gold"
spawner.PICKUP = "pickup"

local OBJECT_SIZE = 22
local GOLD_CHANCE = 0.07
local FOOD_CHANCE = 0.60
local PICKUP_CHANCE = 0.05

local TIME = 0
local mode = { enemy_chance = 0.4, spawn_mul = 1 }
local player_ref = nil

function spawner.set_player(p)
  player_ref = p
end

function spawner.configure(m)
  mode = m or mode
end

function spawner.reset()
  spawner.objects = {}
  spawner.timer = 0.4
  TIME = 0
end

local function spawn_one()
  local roll = rng.random()
  local kind
  if roll < PICKUP_CHANCE * (world.pickup_mul or 1) then
    local id = pickups.pick(1, rng)
    if id then
      table.insert(spawner.objects, {
        kind = spawner.PICKUP,
        pickup = id,
        x = rng.random(OBJECT_SIZE + 4, 800 - OBJECT_SIZE - 4),
        y = world.fall_direction == 1 and -OBJECT_SIZE or 600 + OBJECT_SIZE,
        size = OBJECT_SIZE,
        seed = rng.random() * math.pi * 2,
        spin = 1,
      })
    end
    return
  end
  local gold_chance = GOLD_CHANCE * (world.gold_mul or 1)
  local enemy_chance = (mode.enemy_chance or 0.4) * (world.enemy_chance_mul or 1)
  if roll < gold_chance then
    kind = spawner.GOLD
  elseif roll < gold_chance + enemy_chance then
    local variant = enemies.pick(world.elapsed, 1, rng)
    table.insert(spawner.objects, {
      kind = spawner.ENEMY,
      variant = variant or "normal",
      hp = enemies.get(variant or "normal").hp,
      x = rng.random(OBJECT_SIZE + 4, 800 - OBJECT_SIZE - 4),
      y = world.fall_direction == 1 and -OBJECT_SIZE or 600 + OBJECT_SIZE,
      size = OBJECT_SIZE,
      seed = rng.random() * math.pi * 2,
      spin = (rng.random() < 0.5 and -1 or 1) * (0.8 + rng.random() * 0.6),
    })
    return
  elseif roll < gold_chance + enemy_chance + FOOD_CHANCE * (1 - enemy_chance) then
    kind = spawner.FOOD
  else
    kind = spawner.FOOD
  end
  table.insert(spawner.objects, {
    kind = kind,
    x = rng.random(OBJECT_SIZE + 4, 800 - OBJECT_SIZE - 4),
    y = world.fall_direction == 1 and -OBJECT_SIZE or 600 + OBJECT_SIZE,
    size = OBJECT_SIZE,
    seed = rng.random() * math.pi * 2,
    spin = (rng.random() < 0.5 and -1 or 1) * (0.8 + rng.random() * 0.6),
  })
end

function spawner.update(dt)
  TIME = TIME + dt
  local events = {}
  spawner.timer = spawner.timer - dt
  if spawner.timer <= 0 then
    spawn_one()
    spawner.timer = world.currentSpawnInterval() / (mode.spawn_mul or 1)
  end

  local freeze = (world.freeze_timer or 0) > 0
  local vy = freeze and 0 or (world.currentFallSpeed() * world.fall_direction)
  for i = #spawner.objects, 1, -1 do
    local obj = spawner.objects[i]
    local type = obj.kind == spawner.ENEMY and enemies.get(obj.variant) or nil
    local speed_mul = type and type.speed_mul * (world.enemy_speed_mul or 1) or 1
    if obj.kind == spawner.FOOD and world.magnet then
      local dx = player_ref and (player_ref.x + player_ref.w / 2 - obj.x) or 0
      local dy = player_ref and (player_ref.y + player_ref.h / 2 - obj.y) or 0
      local d = math.max(1, math.sqrt(dx * dx + dy * dy))
      if player_ref and d < 220 then
        obj.x = obj.x + dx / d * 160 * dt
        obj.y = obj.y + dy / d * 160 * dt
      end
    end
    obj.y = obj.y + vy * speed_mul * dt
    obj.rot = (obj.rot or 0) + (obj.spin or 0) * dt
    local off_screen = (world.fall_direction == 1 and obj.y > 600 + OBJECT_SIZE)
      or (world.fall_direction == -1 and obj.y < -OBJECT_SIZE)
    if off_screen then
      if obj.kind == spawner.ENEMY then
        table.insert(events, { type = "enemy_escaped", x = obj.x, variant = obj.variant })
      else
        table.insert(events, { type = "object_escaped", x = obj.x, kind = obj.kind })
      end
      table.remove(spawner.objects, i)
    end
  end
  return events
end

function spawner.collectHits(player)
  local hits = {}
  for i = #spawner.objects, 1, -1 do
    local obj = spawner.objects[i]
    local r = obj.size * 0.5
    local nearest_x = math.max(player.x, math.min(obj.x, player.x + player.w))
    local nearest_y = math.max(player.y, math.min(obj.y, player.y + player.h))
    local dx = obj.x - nearest_x
    local dy = obj.y - nearest_y
    if dx * dx + dy * dy <= r * r then
      table.insert(hits, obj)
      table.remove(spawner.objects, i)
    end
  end
  return hits
end

function spawner.clear_enemies()
  local removed = 0
  for i = #spawner.objects, 1, -1 do
    if spawner.objects[i].kind == spawner.ENEMY then
      table.remove(spawner.objects, i)
      removed = removed + 1
    end
  end
  return removed
end

function spawner.split(obj)
  local out = {}
  local type = enemies.get(obj.variant)
  if type.splits then
    for i = 1, type.splits do
      table.insert(out, {
        kind = spawner.ENEMY,
        variant = "fast",
        hp = 1,
        x = math.max(24, math.min(776, obj.x + (i == 1 and -30 or 30))),
        y = obj.y,
        size = OBJECT_SIZE,
        seed = rng.random() * math.pi * 2,
        spin = (i == 1 and -1 or 1),
      })
    end
  end
  return out
end

local COLOR_FOOD = theme.green
local COLOR_ENEMY = theme.red
local COLOR_GOLD = theme.yellow

local function paint_for(kind)
  if kind == spawner.GOLD or kind == spawner.PICKUP then
    return COLOR_GOLD
  end
  local show_food = kind == spawner.FOOD
  if world.swap_colors then
    show_food = not show_food
  end
  return show_food and COLOR_FOOD or COLOR_ENEMY
end

local function draw_glow(obj, color, alpha_mul)
  local pulse = 0.65 + 0.35 * math.sin(TIME * 4 + (obj.seed or 0))
  love.graphics.setBlendMode("add")
  love.graphics.setColor(color[1], color[2], color[3], 0.28 * pulse * (alpha_mul or 1))
  love.graphics.circle("fill", obj.x, obj.y, obj.size * (0.9 + 0.35 * pulse))
  love.graphics.setBlendMode("alpha")
end

function spawner.draw()
  local alpha_mul = world.alpha or 1
  for _, obj in ipairs(spawner.objects) do
    local color = obj.kind == spawner.PICKUP and theme.cyan or paint_for(obj.kind)
    draw_glow(obj, color, alpha_mul)
    love.graphics.setColor(color[1], color[2], color[3], alpha_mul)

    if obj.kind == spawner.FOOD or obj.kind == spawner.GOLD or obj.kind == spawner.PICKUP then
      love.graphics.push()
      love.graphics.translate(obj.x, obj.y)
      love.graphics.rotate(obj.rot or 0)
      local s = obj.size
      love.graphics.rectangle("fill", -s * 0.5, -s * 0.5, s, s, 5, 5)
      love.graphics.setColor(1, 1, 1, 0.4 * alpha_mul)
      love.graphics.rectangle("fill", -s * 0.32, -s * 0.32, s * 0.64, s * 0.3, 3, 3)
      if obj.kind ~= spawner.FOOD then
        love.graphics.setColor(1, 1, 1, 0.85 * alpha_mul)
        local r = s * 0.24
        love.graphics.polygon(
          "fill",
          0,
          -r,
          r * 0.35,
          -r * 0.35,
          r,
          0,
          r * 0.35,
          r * 0.35,
          0,
          r,
          -r * 0.35,
          r * 0.35,
          -r,
          0,
          -r * 0.35,
          -r * 0.35
        )
      end
      love.graphics.setColor(0, 0, 0, 0.25 * alpha_mul)
      love.graphics.setLineWidth(2)
      love.graphics.rectangle("line", -s * 0.5, -s * 0.5, s, s, 5, 5)
      love.graphics.setLineWidth(1)
      love.graphics.pop()
    else
      local type = enemies.get(obj.variant)
      local r = obj.size * 0.68
      local wobble = (obj.rot or 0) * 0.35 + math.sin(TIME * 2.2 + obj.seed) * 0.18
      local a = (type.alpha or 1) * alpha_mul
      love.graphics.push()
      love.graphics.translate(obj.x, obj.y)
      love.graphics.rotate(wobble)
      love.graphics.setColor(color[1], color[2], color[3], a)
      love.graphics.polygon("fill", 0, -r, r * 0.95, r * 0.72, -r * 0.95, r * 0.72)
      love.graphics.setColor(1, 1, 1, 0.3 * a)
      love.graphics.polygon("fill", 0, -r * 0.55, r * 0.48, r * 0.42, -r * 0.48, r * 0.42)
      love.graphics.setColor(0, 0, 0, 0.3 * a)
      love.graphics.polygon("line", 0, -r, r * 0.95, r * 0.72, -r * 0.95, r * 0.72)
      love.graphics.pop()
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return spawner
