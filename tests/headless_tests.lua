-- tests/headless_tests.lua
-- Headless unit tests for Flip30, run with LuaJIT (the same VM LÖVE ships):
--
--   luajit tests/headless_tests.lua
--
-- Pure-logic modules only (world, player, spawner, storage, rulemanager).
-- Anything that needs love.graphics/love.audio is exercised in-engine
-- via `love . --screenshot` instead.

package.path = "./?.lua;" .. package.path
math.randomseed(12345)

local failures = 0
local passes = 0

local function check(condition, label)
  if condition then
    passes = passes + 1
  else
    failures = failures + 1
    io.write("FAIL: " .. label .. "\n")
  end
end

local world = require("src.world")
local player = require("src.player")
local spawner = require("src.spawner")
local storage = require("src.storage")
local rulemanager = require("src.rulemanager")

-- ---------------------------------------------------------------- world
world.reset()
check(world.fall_speed == 200, "world default fall_speed")
check(world.gravity == 1 and world.fall_direction == 1 and world.speed_mul == 1, "world neutral defaults")
check(world.currentFallSpeed() == 200, "currentFallSpeed at t=0")
world.update(10)
check(math.abs(world.currentFallSpeed() - (200 + 6 * 10)) < 1e-6, "fall speed grows with elapsed")
check(world.currentSpawnInterval() <= 0.8, "spawn interval shrinks with elapsed")
world.elapsed = 1000
check(world.currentSpawnInterval() >= world.spawn_interval_min / world.speed_mul, "spawn interval respects the floor")
world.reset()
check(world.elapsed == 0 and world.currentFallSpeed() == 200, "world.reset restores defaults")

-- combo multiplier
check(world.comboMultiplier(0) == 1, "combo 0 is level 1")
check(world.comboMultiplier(3) == 1, "combo 3 is level 1")
check(world.comboMultiplier(4) == 2, "combo 4 is level 2")
check(world.comboMultiplier(8) == 3, "combo 8 is level 3")
check(world.comboMultiplier(16) == 5, "combo 16 is level 5")
check(world.comboMultiplier(100) == 5, "combo 100 caps at level 5")
check(world.comboMultiplier(-1) == 1, "combo negative is level 1")
check(world.comboMultiplier(nil) == 1, "combo nil is level 1")

-- spawn_rate_mul scales the interval
world.reset()
world.spawn_rate_mul = 2
check(world.currentSpawnInterval() <= 0.4, "HUJAN halves spawn interval")
world.reset()

-- score_mul does not break defaults
world.reset()
check(world.score_mul == 1, "score_mul defaults to 1")
world.reset()

-- ---------------------------------------------------------------- storage
check(storage.parse("123") == 123, "storage.parse integer")
check(storage.parse("  42\n") == 42, "storage.parse trims whitespace")
check(storage.parse("9.9") == 9, "storage.parse truncates floats")
local st = storage.parseStats("120 3400 55")
check(st.time == 120 and st.score == 3400 and st.food == 55, "parseStats parses three fields")
st = storage.parseStats("garbage")
check(st.time == 0 and st.score == 0 and st.food == 0, "parseStats rejects garbage")
st = storage.parseStats("12")
check(st.time == 0 and st.score == 0 and st.food == 0, "parseStats rejects short input")
st = storage.parseStats(nil)
check(st.time == 0 and st.score == 0 and st.food == 0, "parseStats rejects nil")
check(storage.parse("abc") == 0, "storage.parse corrupt string")
check(storage.parse("") == 0, "storage.parse empty string")
check(storage.parse("-7") == 0, "storage.parse negative score")
check(storage.parse(nil) == 0, "storage.parse nil")

-- ---------------------------------------------------------------- player
player.reset()
check(player.x == (800 - 40) / 2, "player reset centers x")
player.update(0.5, true, false, 1)
check(player.x == (800 - 40) / 2 - 200, "player moves left at base speed")
player.x = 0
player.update(1, true, false, 1)
check(player.x == 0, "player clamps at left wall")
player.x = 790
player.update(1, false, true, 1)
check(player.x == 760, "player clamps at right wall")
player.reset()
player.dir = -1
player.update(0.5, true, false, 1)
check(player.x == (800 - 40) / 2 + 200, "KONTROL TERBALIK-style dir flip")
player.reset()
player.always_move = true
player.update(0.5, false, false, 1)
check(player.x == (800 - 40) / 2 + 200, "TIDAK BISA BERHENTI keeps moving right")
player.reset()

-- ---------------------------------------------------------------- spawner
spawner.reset()
check(#spawner.objects == 0 and spawner.timer > 0, "spawner reset")
local spawned = false
for _ = 1, 600 do
  spawner.update(1 / 60)
  if #spawner.objects > 0 then
    spawned = true
    break
  end
end
check(spawned, "spawner spawns within 10 simulated seconds")
spawner.reset()
table.insert(spawner.objects, { kind = spawner.FOOD, x = 400, y = 700, size = 22 })
local events = spawner.update(1 / 60)
check(#events == 1 and events[1].type == "food_escaped", "off-screen food emits food_escaped")
check(#spawner.objects == 0, "off-screen food is culled")
spawner.reset()
table.insert(spawner.objects, { kind = spawner.FOOD, x = 400, y = 540, size = 22 })
local hits = spawner.collectHits({ x = 380, y = 520, w = 40, h = 40 })
check(#hits == 1 and hits[1].kind == spawner.FOOD, "collectHits detects overlap")
spawner.reset()
table.insert(spawner.objects, { kind = spawner.ENEMY, x = 10, y = 10, size = 22 })
hits = spawner.collectHits({ x = 380, y = 520, w = 40, h = 40 })
check(#hits == 0 and #spawner.objects == 1, "collectHits ignores distant objects")

-- ---------------------------------------------------------- rulemanager
local function snapshot()
  return {
    fall_speed = world.fall_speed,
    fall_speed_growth = world.fall_speed_growth,
    spawn_interval = world.spawn_interval,
    spawn_interval_decay = world.spawn_interval_decay,
    spawn_interval_min = world.spawn_interval_min,
    speed_mul = world.speed_mul,
    gravity = world.gravity,
    fall_direction = world.fall_direction,
    enemy_gives_points = world.enemy_gives_points,
    enemy_points = world.enemy_points,
    enemy_escape_penalty = world.enemy_escape_penalty,
    enemy_life_damage = world.enemy_life_damage,
    swap_colors = world.swap_colors,
    darkness = world.darkness,
    spawn_rate_mul = world.spawn_rate_mul,
    score_mul = world.score_mul,
    dir = player.dir,
    w = player.w,
    always_move = player.always_move,
    last_dir = player.last_dir,
  }
end

local function snapshots_equal(a, b)
  for key, value in pairs(a) do
    if b[key] ~= value then
      return false, key
    end
  end
  return true
end

local bundled_rule_files = {
  "rules/reverse_controls.lua",
  "rules/gravity_off.lua",
  "rules/gravity_up.lua",
  "rules/enemy_points.lua",
  "rules/swap_colors.lua",
  "rules/dark_room.lua",
  "rules/all_fast.lua",
  "rules/no_stop.lua",
  "rules/double_spawn.lua",
  "rules/double_score.lua",
  "rules/big_player.lua",
  "rules/small_player.lua",
  "rules/gravity_turbulent.lua",
}

local ctx = { world = world, player = player, spawner = spawner, ui = nil, sfx = nil }

local bundled_rules = {}
for _, path in ipairs(bundled_rule_files) do
  local chunk, load_err = loadfile(path)
  check(chunk ~= nil, "loadfile " .. path .. ": " .. tostring(load_err))
  if chunk then
    local ok, rule = pcall(chunk)
    check(ok and type(rule) == "table", "rule file returns a table: " .. path)
    if ok and type(rule) == "table" then
      table.insert(bundled_rules, rule)
    end
  end
end
check(#bundled_rules == #bundled_rule_files, "all bundled rules load")

for _, rule in ipairs(bundled_rules) do
  world.reset()
  player.reset()
  -- every bundled rule must carry a non-empty hint
  check(type(rule.hint) == "string" and #rule.hint > 0, "hint present: " .. tostring(rule.name))
  local before = snapshot()
  local ok_apply, err_apply = pcall(rule.apply, ctx)
  check(ok_apply, "apply does not error: " .. tostring(rule.name) .. " (" .. tostring(err_apply) .. ")")
  local ok_revert, err_revert = pcall(rule.revert, ctx)
  check(ok_revert, "revert does not error: " .. tostring(rule.name) .. " (" .. tostring(err_revert) .. ")")
  local same, differing_key = snapshots_equal(before, snapshot())
  check(same, "apply/revert restores state for " .. rule.name .. " (differs: " .. tostring(differing_key) .. ")")
end

-- registerRule validation
check(rulemanager.registerRule(nil, "bad-1") == false, "registerRule rejects nil")
check(rulemanager.registerRule({}, "bad-2") == false, "registerRule rejects nameless rule")
check(rulemanager.registerRule({ name = "x" }, "bad-3") == false, "registerRule rejects missing apply/revert")

-- swap cycle: reset state and flip 40 times, must never crash or stick
rulemanager.rules = {}
for _, rule in ipairs(bundled_rules) do
  rulemanager.registerRule(rule, "bundled")
end
rulemanager.active = {}
rulemanager.last_name = nil
rulemanager.max_active = 1
rulemanager.timer = 30

for i = 1, 40 do
  rulemanager.swap(ctx)
  check(rulemanager.timer == rulemanager.rule_duration, "swap resets timer (iteration " .. i .. ")")
  check(#rulemanager.active <= 1, "max_active respected (iteration " .. i .. ")")
  if #rulemanager.active == 1 and i > 1 then
    -- gravity rules share a tag; only one can be active at a time anyway
    check(rulemanager.active[1].name == rulemanager.last_name, "active rule tracked")
  end
end

-- tag conflict: two gravity rules must never be active together
rulemanager.rules = {}
for _, rule in ipairs(bundled_rules) do
  if rule.name == "GRAVITASI MATI" or rule.name == "GRAVITASI NAIK" then
    rulemanager.registerRule(rule, "bundled")
  end
end
rulemanager.active = {}
rulemanager.last_name = nil
rulemanager.max_active = 2
rulemanager.swap(ctx)
check(#rulemanager.active == 1, "tag conflict prevents two gravity rules active at once")

-- two-minute escalation: two tag-disjoint rules activate together
rulemanager.rules = {}
for _, rule in ipairs(bundled_rules) do
  rulemanager.registerRule(rule, "bundled")
end
rulemanager.active = {}
rulemanager.last_name = nil
rulemanager.max_active = 2
rulemanager.swap(ctx)
check(#rulemanager.active == 2, "two-minute escalation picks two rules")
if #rulemanager.active == 2 then
  local a, b = rulemanager.active[1], rulemanager.active[2]
  local clash = false
  for _, t in ipairs(a.tags or {}) do
    for _, u in ipairs(b.tags or {}) do
      if t == u then
        clash = true
      end
    end
  end
  check(not clash, "two-minute escalation never picks two same-tag rules")
end
-- a gravity pair can never be chosen even at max_active = 2
rulemanager.rules = {}
for _, rule in ipairs(bundled_rules) do
  if rule.name == "GRAVITASI MATI" or rule.name == "GRAVITASI NAIK" then
    rulemanager.registerRule(rule, "bundled")
  end
end
rulemanager.active = {}
rulemanager.last_name = nil
rulemanager.max_active = 2
rulemanager.swap(ctx)
check(#rulemanager.active == 1, "max_active=2 still blocks the gravity pair")
-- restore full state for the next scenario
rulemanager.rules = {}
for _, rule in ipairs(bundled_rules) do
  rulemanager.registerRule(rule, "bundled")
end
rulemanager.active = {}
rulemanager.last_name = nil
rulemanager.max_active = 1
rulemanager.swap(ctx)
check(#rulemanager.active == 1, "max_active=1 restores single rule")

-- resetToDefaults restores player and world after rules were applied
rulemanager.max_active = 1
rulemanager.swap(ctx) -- applies GRAVITASI MATI or NAIK
rulemanager.resetToDefaults(ctx)
check(world.gravity == 1 and world.fall_direction == 1, "resetToDefaults clears gravity rules")
check(player.dir == 1 and not player.always_move, "resetToDefaults restores player")
check(#rulemanager.active == 0 and rulemanager.last_name == nil, "resetToDefaults clears rule state")

-- ---------------------------------------------------------------- summary
io.write(string.format("\n%d passed, %d failed\n", passes, failures))
os.exit(failures == 0 and 0 or 1)
