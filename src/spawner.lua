-- src/spawner.lua
-- Spawns and moves falling objects: FOOD (green, +10) and ENEMY (red, -1 life).
-- TUKAR WARNA only repaints them; shape and behaviour follow `kind`, never color.

local world = require("src.world")

local spawner = {}

spawner.FOOD = "food"
spawner.ENEMY = "enemy"

local OBJECT_SIZE = 22
local FOOD_CHANCE = 0.6

local COLOR_FOOD = { 0.24, 0.86, 0.54 } -- green
local COLOR_ENEMY = { 1.00, 0.30, 0.36 } -- red

function spawner.reset()
  spawner.objects = {}
  spawner.timer = 0.4 -- first object arrives quickly
end

local function spawn_one()
  local kind = math.random() < FOOD_CHANCE and spawner.FOOD or spawner.ENEMY
  local x = math.random(OBJECT_SIZE + 4, 800 - OBJECT_SIZE - 4)
  local y = world.fall_direction == 1 and -OBJECT_SIZE or 600 + OBJECT_SIZE
  table.insert(spawner.objects, {
    kind = kind,
    x = x,
    y = y,
    size = OBJECT_SIZE,
  })
end

-- Advances timers and object motion. Returns a list of events
-- ({ type = "enemy_escaped" | "food_escaped", x = ... }) for the game module.
function spawner.update(dt)
  local events = {}
  spawner.timer = spawner.timer - dt
  if spawner.timer <= 0 then
    spawn_one()
    spawner.timer = world.currentSpawnInterval()
  end

  local vy = world.currentFallSpeed() * world.fall_direction
  for i = #spawner.objects, 1, -1 do
    local obj = spawner.objects[i]
    obj.y = obj.y + vy * dt
    local off_screen = (world.fall_direction == 1 and obj.y > 600 + OBJECT_SIZE)
      or (world.fall_direction == -1 and obj.y < -OBJECT_SIZE)
    if off_screen then
      if obj.kind == spawner.ENEMY then
        table.insert(events, { type = "enemy_escaped", x = obj.x })
      else
        table.insert(events, { type = "food_escaped", x = obj.x })
      end
      table.remove(spawner.objects, i)
    end
  end
  return events
end

-- Removes objects overlapping the player rectangle. Returns the list of hit objects.
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

local function paint_for(kind)
  -- TUKAR WARNA swaps the palette; behaviour keeps following `kind`.
  local show_food = kind == spawner.FOOD
  if world.swap_colors then
    show_food = not show_food
  end
  return show_food and COLOR_FOOD or COLOR_ENEMY
end

function spawner.draw()
  for _, obj in ipairs(spawner.objects) do
    local color = paint_for(obj.kind)
    love.graphics.setColor(color[1], color[2], color[3], 1)

    if obj.kind == spawner.FOOD then
      love.graphics.circle("fill", obj.x, obj.y, obj.size * 0.5)
      love.graphics.setColor(1, 1, 1, 0.35)
      love.graphics.circle("fill", obj.x - obj.size * 0.15, obj.y - obj.size * 0.15, obj.size * 0.18)
    else
      local r = obj.size * 0.62
      love.graphics.polygon(
        "fill",
        obj.x,
        obj.y - r,
        obj.x + r * 0.95,
        obj.y + r * 0.75,
        obj.x - r * 0.95,
        obj.y + r * 0.75
      )
      love.graphics.setColor(1, 1, 1, 0.25)
      love.graphics.polygon(
        "fill",
        obj.x,
        obj.y - r * 0.55,
        obj.x + r * 0.5,
        obj.y + r * 0.45,
        obj.x - r * 0.5,
        obj.y + r * 0.45
      )
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return spawner
