-- src/enemies.lua
-- Enemy variants with distinct behaviour. Spawner asks this module which
-- variant to spawn; game.lua delegates on-hit behaviour here.

local enemies = {}

enemies.TYPES = {
  normal = {
    name = "MUSUH",
    speed_mul = 1,
    hp = 1,
    color = "red",
    score = 0,
  },
  fast = {
    name = "CEPAT",
    speed_mul = 1.8,
    hp = 1,
    color = "orange",
    score = 5,
  },
  armored = {
    name = "ZIRAH",
    speed_mul = 0.7,
    hp = 2,
    color = "panel_line",
    score = 15,
  },
  splitter = {
    name = "PELAKU",
    speed_mul = 1.1,
    hp = 1,
    color = "pink",
    score = 10,
    splits = 2,
  },
  phantom = {
    name = "HANTU",
    speed_mul = 1.3,
    hp = 1,
    color = "cyan",
    score = 12,
    alpha = 0.45,
  },
  bomb = {
    name = "BOM",
    speed_mul = 0.8,
    hp = 1,
    color = "yellow",
    score = 0,
    blast = true,
  },
}

local order = { "normal", "fast", "armored", "splitter", "phantom", "bomb" }

-- Unlocked variants grow with play time. Zen mode has no enemies at all.
function enemies.pick(elapsed, chance, rng)
  if chance <= 0 then
    return nil
  end
  if rng.random() > chance then
    return nil
  end
  local available = 1
  if elapsed >= 30 then
    available = 2
  end
  if elapsed >= 75 then
    available = 3
  end
  if elapsed >= 150 then
    available = 4
  end
  if elapsed >= 240 then
    available = 5
  end
  if elapsed >= 360 then
    available = 6
  end
  local id = order[rng.random(1, available)]
  return id, enemies.TYPES[id]
end

function enemies.get(id)
  return enemies.TYPES[id] or enemies.TYPES.normal
end

return enemies
