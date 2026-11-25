-- src/spawner.lua
-- Spawns and moves falling objects: FOOD (green note, +10) and ENEMY (red spike, -1 life).
-- TUKAR WARNA only repaints them; shape and behaviour follow `kind`, never color.

local world = require("src.world")
local theme = require("src.theme")

local spawner = {}

spawner.FOOD = "food"
spawner.ENEMY = "enemy"
spawner.GOLD = "gold"

local OBJECT_SIZE = 22
local GOLD_CHANCE = 0.07 -- rare shiny drop, +50
local FOOD_CHANCE = 0.60 -- probability of FOOD among non-gold rolls

local TIME = 0 -- animation clock, advanced in update()

function spawner.reset()
  spawner.objects = {}
  spawner.timer = 0.4 -- first object arrives quickly
  TIME = 0
end

local function spawn_one()
  local roll = math.random()
  local kind
  local gold_chance = GOLD_CHANCE * (world.gold_mul or 1)
  if roll < gold_chance then
    kind = spawner.GOLD
  elseif roll < GOLD_CHANCE + FOOD_CHANCE then
    kind = spawner.FOOD
  else
    kind = spawner.ENEMY
  end
  local x = math.random(OBJECT_SIZE + 4, 800 - OBJECT_SIZE - 4)
  local y = world.fall_direction == 1 and -OBJECT_SIZE or 600 + OBJECT_SIZE
  table.insert(spawner.objects, {
    kind = kind,
    x = x,
    y = y,
    size = OBJECT_SIZE,
    seed = math.random() * math.pi * 2, -- per-object pulse phase
    spin = (math.random() < 0.5 and -1 or 1) * (0.8 + math.random() * 0.6),
  })
end

-- Advances timers and object motion. Returns a list of events
-- ({ type = "enemy_escaped" | "food_escaped", x = ... }) for the game module.
function spawner.update(dt)
  TIME = TIME + dt
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
    obj.rot = (obj.rot or 0) + (obj.spin or 0) * dt
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

local COLOR_FOOD = theme.green
local COLOR_ENEMY = theme.red
local COLOR_GOLD = theme.yellow

local function paint_for(kind)
  if kind == spawner.GOLD then
    return COLOR_GOLD -- gold is exempt from TUKAR WARNA
  end
  -- TUKAR WARNA swaps the palette; behaviour keeps following `kind`.
  local show_food = kind == spawner.FOOD
  if world.swap_colors then
    show_food = not show_food
  end
  return show_food and COLOR_FOOD or COLOR_ENEMY
end

-- Additive glow halo behind each object; cheap enough for a handful of objects.
local function draw_glow(obj, color, alpha_mul)
  local pulse = 0.65 + 0.35 * math.sin(TIME * 4 + (obj.seed or 0))
  local radius = obj.size * (0.9 + 0.35 * pulse)
  love.graphics.setBlendMode("add")
  love.graphics.setColor(color[1], color[2], color[3], 0.28 * pulse * (alpha_mul or 1))
  love.graphics.circle("fill", obj.x, obj.y, radius)
  love.graphics.setBlendMode("alpha")
end

function spawner.draw()
  local alpha_mul = world.alpha or 1
  for _, obj in ipairs(spawner.objects) do
    local color = paint_for(obj.kind)
    draw_glow(obj, color, alpha_mul)
    love.graphics.setColor(color[1], color[2], color[3], alpha_mul)

    if obj.kind == spawner.FOOD or obj.kind == spawner.GOLD then
      -- Yellow-green note-or-gold, slight tumble so it reads as catching something physical
      love.graphics.push()
      love.graphics.translate(obj.x, obj.y)
      love.graphics.rotate(obj.rot or 0)
      local s = obj.size
      love.graphics.rectangle("fill", -s * 0.5, -s * 0.5, s, s, 5, 5)
      love.graphics.setColor(1, 1, 1, 0.4 * alpha_mul)
      love.graphics.rectangle("fill", -s * 0.32, -s * 0.32, s * 0.64, s * 0.3, 3, 3)
      if obj.kind == spawner.GOLD then
        -- sparkle star behind the highlight, unmistakably gold
        love.graphics.setColor(1.000, 1.000, 1.000, 0.85 * alpha_mul)
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
      -- Red spike with a slow wobble spin
      local r = obj.size * 0.68
      local wobble = (obj.rot or 0) * 0.35 + math.sin(TIME * 2.2 + obj.seed) * 0.18
      love.graphics.push()
      love.graphics.translate(obj.x, obj.y)
      love.graphics.rotate(wobble)
      love.graphics.setColor(color[1], color[2], color[3], alpha_mul)
      love.graphics.polygon("fill", 0, -r, r * 0.95, r * 0.72, -r * 0.95, r * 0.72)
      love.graphics.setColor(1, 1, 1, 0.3 * alpha_mul)
      love.graphics.polygon("fill", 0, -r * 0.55, r * 0.48, r * 0.42, -r * 0.48, r * 0.42)
      love.graphics.setColor(0, 0, 0, 0.3 * alpha_mul)
      love.graphics.polygon("line", 0, -r, r * 0.95, r * 0.72, -r * 0.95, r * 0.72)
      love.graphics.pop()
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return spawner
