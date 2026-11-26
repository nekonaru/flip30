-- src/world.lua
-- Central store for every mutable world parameter. Rules apply/revert their
-- changes here, so `world.reset()` always restores clean defaults before a
-- new run starts.

local world = {}

local DEFAULTS = {
  -- Difficulty baseline (grows over time, see world.update)
  fall_speed = 200, -- base fall speed in px/s at t = 0
  fall_speed_growth = 6, -- extra px/s gained per second of play time
  spawn_interval = 0.8, -- seconds between spawns at t = 0
  spawn_interval_decay = 0.012,
  spawn_interval_min = 0.35,

  -- Parameters mutated by rules
  speed_mul = 1, -- global speed multiplier (SEMUA 2X CEPAT)
  gravity = 1, -- 1 = normal, ~0.08 = floaty (GRAVITASI MATI)
  fall_direction = 1, -- 1 = down, -1 = up (GRAVITASI NAIK)
  enemy_gives_points = false, -- MUSUH JADI POIN
  enemy_points = 15,
  enemy_escape_penalty = 5,
  enemy_life_damage = 1,
  swap_colors = false, -- TUKAR WARNA
  darkness = 0, -- LAYAR GELAP strength, 0..1
  alpha = 1, -- HANTU: global object opacity, 1 = solid
  wrap = false, -- TANPA BATAS: player wraps around the arena edge
  gold_mul = 1, -- HUJAN EMAS: multiplier on the golden drop chance
  enemy_chance_mul = 1, -- HUJAN MUSUH: enemy chance multiplier
  pickup_mul = 1, -- pickup drop multiplier
  freeze_timer = 0, -- FREEZE: object motion paused
  combo_step = 4, -- combo catches per multiplier level
  score_per_sec = 0, -- PASSIVE: score earned per survived second
  no_penalty = false, -- escape penalty disabled
  enemy_speed_mul = 1, -- MUSUH LAMBAT: enemy speed multiplier
  magnet = false, -- MAGNET: food drifts toward the player
  time_bonus = 0, -- WAKTU TAMBAH: rule timer added per catch
  xp_mul = 1, -- XP GANDA
  coin_mul = 1, -- KOIN GANDA
  revive = 0, -- NYAWA CADANGAN: free revive on death
  spawn_rate_mul = 1, -- HUJAN: multiplier on the spawn rate
  score_mul = 1, -- SKOR GANDA: multiplier on score gains

  elapsed = 0, -- play time in seconds, drives difficulty
}

function world.reset()
  for key, value in pairs(DEFAULTS) do
    world[key] = value
  end
end

function world.update(dt)
  world.elapsed = world.elapsed + dt
  if world.freeze_timer then
    world.freeze_timer = math.max(0, world.freeze_timer - dt)
  end
end

-- Effective fall speed after difficulty scaling and rule modifiers.
function world.currentFallSpeed()
  local base = world.fall_speed + world.fall_speed_growth * world.elapsed
  return base * world.speed_mul * world.gravity
end

-- Effective spawn interval after difficulty scaling and rule modifiers.
function world.currentSpawnInterval()
  local interval = world.spawn_interval - world.spawn_interval_decay * world.elapsed
  if interval < world.spawn_interval_min then
    interval = world.spawn_interval_min
  end
  return interval / (world.speed_mul * world.spawn_rate_mul)
end

-- Combo multiplier from a streak of consecutive catches.
-- Every 4 catches in a row raises the multiplier, capped at x5.
function world.comboMultiplier(streak)
  if type(streak) ~= "number" or streak < 0 then
    return 1
  end
  local level = math.floor(streak / (world.combo_step or 4)) + 1
  if level > 5 then
    level = 5
  end
  return level
end

world.reset()

return world
