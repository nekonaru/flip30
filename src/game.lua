-- src/game.lua
-- Flip30 v2.0 state machine and main loop.

local world = require("src.world")
local player = require("src.player")
local spawner = require("src.spawner")
local storage = require("src.storage")
local ui = require("src.ui")
local rulemanager = require("src.rulemanager")
local particles = require("src.particles")
local sfx = require("src.sfx")
local theme = require("src.theme")
local debugpanel = require("src.debugpanel")
local music = require("src.music")
local modes = require("src.modes")
local enemies = require("src.enemies")
local pickups = require("src.pickups")
local abilities = require("src.abilities")
local settings = require("src.settings")
local progression = require("src.progression")
local achievements = require("src.achievements")
local shop = require("src.shop")
local daily = require("src.daily")
local replay = require("src.replay")
local codex = require("src.codex")
local boss = require("src.boss")
local rng = require("src.rng")

local game = {
  state = "menu", -- "menu" | "playing" | "gameover"
  score = 0,
  display_score = 0,
  lives = 3,
  highscore = 0,
  new_record = false,
  time = 0,
  run_time = 0,
  paused = false,
  trauma = 0,
  shake_t = 0,
  hit_stop = 0,
  flash = 0,
  food_count = 0,
  combo = 0,
  combo_best = 0,
  best_combo_ever = 0,
  muted = false,
  coins = 0,
  mode = modes.get("classic"),
  mode_time = 0,
  seed = 0,
  effects = { magnet = 0, shield = 0, freeze = 0, double = 0 },
  ab = abilities.new(),
  boss = boss.new(),
  rec = replay.new(),
  mod_count = 0,
  rules_seen = {},
  bosses_defeated = 0,
  purchases = 0,
  dashes = 0,
  shields_used = 0,
  gold_caught = 0,
  profile_slot = 1,
  profile = progression.new(),
  profiles = {},
  settings = settings.default(),
  codex_entries = {},
  draft_options = nil,
  show_shop = false,
}

local COLOR_GREEN = theme.green
local COLOR_RED = theme.red
local COLOR_ORANGE = theme.orange

function game.load()
  ui.load()
  music.load()
  ui.version = "2.0.0"
  game.highscore = storage.load()
  game.best_combo_ever = storage.loadBestCombo()
  game.games_count = storage.loadGamesCount()
  game.stats = storage.loadStats()
  game.top_scores = storage.loadScores()
  game.settings = settings.load()
  for i = 1, 3 do
    game.profiles[i] = progression.load(i)
  end
  game.profile = game.profiles[game.profile_slot]
  game.time = 0
  game.ctx = {
    player = player,
    world = world,
    spawner = spawner,
    ui = ui,
    sfx = sfx,
    rulemanager = rulemanager,
    music = music,
    game = game,
  }
  sfx.load()
  particles.load()
  spawner.set_player(player)
  local modloader = require("src.modloader")
  local ok_mods, mods = pcall(modloader.loadMods)
  if ok_mods and #mods > 0 then
    rulemanager.loadRules(mods)
    game.mod_count = #mods
  else
    rulemanager.loadRules()
    game.mod_count = 0
  end
  game.codex_entries = codex.build(rulemanager)
  rulemanager.resetToDefaults(game.ctx)
  spawner.reset()
  game.apply_settings()
end

function game.apply_settings()
  sfx.muted = game.muted
  sfx.volume = game.settings.sfx_volume or 1
  music.muted = game.muted
  if music._src and music._src.setVolume then
    music._src:setVolume(game.settings.music_volume or 0.18)
  end
  if (game.settings.colorblind or 0) > 0 then
    theme.green = { 0.20, 0.55, 1.00 }
    theme.red = { 1.00, 0.72, 0.10 }
  else
    theme.green = { 0.239, 0.859, 0.541 }
    theme.red = { 1.000, 0.302, 0.361 }
  end
end

function game.export_profile()
  if not (love and love.filesystem) then
    return false
  end
  local data = progression.serialize(game.profile)
  local ok, written = pcall(love.filesystem.write, "profile_export.txt", data)
  return ok and written and true or false
end

function game.import_profile()
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return false
  end
  local ok, exists = pcall(love.filesystem.getInfo, "profile_export.txt")
  if not ok or not exists then
    return false
  end
  local ok_read, data = pcall(love.filesystem.read, "profile_export.txt")
  if not ok_read then
    return false
  end
  game.profile = progression.parse(data)
  game.profiles[game.profile_slot] = game.profile
  progression.save(game.profile_slot, game.profile)
  game.apply_settings()
  return true
end

function game.setMute(muted)
  game.muted = muted
  sfx.muted = muted
  music.muted = muted
end

function game.startRun(mode_id)
  local mode = modes.get(mode_id or game.mode.id)
  game.mode = mode
  spawner.configure(mode)
  rulemanager.resetToDefaults(game.ctx)
  rulemanager.max_active = mode.start_rules > 1 and 3 or 1
  rulemanager.draft = mode.id == "chaos"
  if mode.id == "daily" then
    rng.set_seed(daily.seed())
  elseif mode.id == "chaos" then
    rng.set_seed(os.time())
  else
    rng.set_seed(math.floor(love.timer.getTime() * 1000) % 2147483648)
  end
  game.seed = rng.get_seed()
  replay.begin(game.rec, game.seed, mode.id)
  spawner.reset()
  music.play(game.ctx)
  game.games_count = game.games_count + 1
  storage.saveGamesCount(game.games_count)
  game.score, game.display_score = 0, 0
  game.food_count = 0
  game.lives = 3
  game.new_record = false
  game.run_time = 0
  game.mode_time = 0
  game.combo = 0
  game.combo_best = 0
  game.paused = false
  game.trauma = 0
  game.shake_t = 0
  game.hit_stop = 0
  game.flash = 0
  game.coins = 0
  game.effects = { magnet = 0, shield = 0, freeze = 0, double = 0 }
  abilities.reset(game.ab)
  game.rules_seen = {}
  game.bosses_defeated = 0
  game.purchases = 0
  game.dashes = 0
  game.shields_used = 0
  game.gold_caught = 0
  game.show_shop = false
  ui.show_stats = false
  ui.screen = nil
  game.state = "playing"
end

local function run_summary()
  local seen = 0
  for _ in pairs(game.rules_seen or {}) do
    seen = seen + 1
  end
  return {
    runs = game.games_count,
    best = game.highscore,
    combo = math.max(game.combo_best, game.best_combo_ever),
    time = math.floor(game.run_time),
    gold = game.gold_caught,
    rules_seen = seen,
    mods = game.mod_count,
    modes = {
      blitz = game.mode.id == "blitz" and 1 or 0,
      zen = game.mode.id == "zen" and 1 or 0,
      chaos = game.mode.id == "chaos" and 1 or 0,
      daily = game.mode.id == "daily" and 1 or 0,
    },
    bosses = game.bosses_defeated,
    shields = game.shields_used,
    dashes = game.dashes,
    purchases = game.purchases,
  }
end

function game.gameOver()
  game.state = "gameover"
  music.stop()
  replay.stop(game.rec)
  game.display_score = game.score
  if game.combo_best > game.best_combo_ever then
    game.best_combo_ever = game.combo_best
    storage.saveBestCombo(game.combo_best)
  end
  local stats = game.stats or { time = 0, score = 0, food = 0 }
  stats.time = stats.time + game.run_time
  stats.score = stats.score + game.score
  stats.food = stats.food + game.food_count
  storage.saveStats(stats)
  game.stats = stats
  if game.score > 0 then
    local scores = {}
    for i, value in ipairs(game.top_scores or {}) do
      scores[i] = value
    end
    table.insert(scores, game.score)
    table.sort(scores, function(a, b)
      return a > b
    end)
    while #scores > 5 do
      table.remove(scores)
    end
    game.top_scores = scores
    storage.saveScores(scores)
  end
  if game.score > game.highscore then
    game.highscore = game.score
    game.new_record = true
    storage.save(game.highscore)
    sfx.play("record")
  else
    sfx.play("gameover")
  end
  local xp = math.floor((game.score + game.food_count * 2) * (world.xp_mul or 1))
  progression.add_xp(game.profile, xp)
  game.profile.coins = game.profile.coins + math.floor(game.score / 10 * (world.coin_mul or 1))
  game.profile.total_runs = game.profile.total_runs + 1
  game.profile.best_score = math.max(game.profile.best_score or 0, game.score)
  progression.save(game.profile_slot, game.profile)
  local summary = run_summary()
  summary.time = math.floor(game.run_time)
  local unlocked = achievements.check_all(game.profile, summary)
  progression.save(game.profile_slot, game.profile)
  if #unlocked > 0 then
    ui.addPopup(400, 180, "PENCAPAIAN: " .. unlocked[1].name, theme.yellow or COLOR_ORANGE)
  end
  particles.burst(player.x + player.w / 2, player.y + player.h / 2, 1.000, 0.243, 0.541, 30)
end

local function add_trauma(amount)
  game.trauma = math.min(1, game.trauma + (game.settings.shake or 1) * amount)
end

local function apply_pickup(id)
  local def = pickups.get(id)
  if not def then
    return
  end
  if def.duration > 0 then
    game.effects[id] = def.duration
  end
  if id == "life" then
    game.lives = game.lives + 1
  elseif id == "skip" then
    rulemanager.choose(game.ctx, 1)
    rulemanager.begin_swap(game.ctx)
  elseif id == "clear" then
    spawner.clear_enemies()
    add_trauma(0.3)
  end
  sfx.play("catch", 1.4)
  ui.addPopup(player.x + 20, player.y - 20, def.name, theme.cyan)
end

local function handle_enemy(hit)
  local type = enemies.get(hit.variant)
  if hit.hp > 1 then
    hit.hp = hit.hp - 1
    add_trauma(0.2)
    particles.burst(hit.x, hit.y, 0.6, 0.6, 0.7, 8)
    sfx.play("hit", 0.8)
    return
  end
  game.combo = 0
  if game.effects.shield > 0 then
    game.effects.shield = 0
    game.shields_used = game.shields_used + 1
    ui.addPopup(hit.x, hit.y, "SHIELD!", theme.cyan)
    sfx.play("catch", 1.2)
  elseif world.enemy_gives_points then
    local points = type.score * (world.score_mul or 1)
    game.score = game.score + points
    player.impact = 0.8
    ui.addPopup(hit.x, hit.y, "+" .. points, COLOR_ORANGE)
    particles.burst(hit.x, hit.y, COLOR_ORANGE[1], COLOR_ORANGE[2], COLOR_ORANGE[3], 14)
    sfx.play("catch")
  else
    game.lives = math.max(0, game.lives - world.enemy_life_damage)
    add_trauma(0.65)
    game.hit_stop = math.max(game.hit_stop, 0.06)
    game.flash = 0.7 * (game.settings.flash or 1)
    player.impact = 1.0
    ui.addPopup(hit.x, hit.y, "-1 NYAWA", COLOR_RED)
    particles.burst(hit.x, hit.y, COLOR_RED[1], COLOR_RED[2], COLOR_RED[3], 20)
    sfx.play("hit")
    if game.lives <= 0 then
      if (world.revive or 0) > 0 then
        world.revive = 0
        game.lives = 1
        ui.addPopup(400, 300, "NYAWA CADANGAN!", theme.yellow)
        sfx.play("record")
      else
        game.gameOver()
      end
    end
  end
  if type.splits then
    for _, obj in ipairs(spawner.split(hit)) do
      table.insert(spawner.objects, obj)
    end
  end
  if type.blast then
    add_trauma(0.4)
    game.flash = 0.4
  end
end

function game.update(dt)
  game.time = game.time + dt
  if game.display_score ~= game.score then
    local diff = game.score - game.display_score
    game.display_score = game.display_score + diff * math.min(1, dt * 9)
    if math.abs(diff) < 1 then
      game.display_score = game.score
    end
  end
  if game.paused or ui.screen or rulemanager.pending then
    return
  end

  local slowmo = ui.bannerActive() and 0.3 or 1
  local focus = game.state == "playing" and game.ab.focus_active and 0.5 or 1
  local hitstop = game.hit_stop > 0 and 0.08 or 1
  local sim_dt = dt * slowmo * focus * hitstop
  game.hit_stop = math.max(0, game.hit_stop - dt)
  game.trauma = math.max(0, game.trauma - dt * 1.5)
  game.shake_t = game.shake_t + dt * 42

  if game.state == "playing" then
    game.run_time = game.run_time + dt
    game.mode_time = game.mode_time + dt
    if game.mode.time_limit > 0 and game.mode_time >= game.mode.time_limit then
      game.gameOver()
      return
    end

    for key, value in pairs(game.effects) do
      game.effects[key] = math.max(0, value - dt)
    end
    world.freeze_timer = game.effects.freeze
    abilities.update(game.ab, dt, love.keyboard.isDown("space"))

    rulemanager.update(game.ctx, dt)
    for _, rule in ipairs(rulemanager.active) do
      game.rules_seen[rule.name] = true
    end
    world.update(sim_dt)
    if world.score_per_sec > 0 then
      game.score = game.score + world.score_per_sec * dt
    end

    local left = love.keyboard.isDown("a", "left")
    local right = love.keyboard.isDown("d", "right")
    player.update(sim_dt, left, right, world.speed_mul, world.wrap)
    local dash_mul = game.ab.dash_cd > abilities.DASH_CD - 0.15 and 3 or 1
    if dash_mul > 1 then
      player.x = math.max(0, math.min(800 - player.w, player.x + (right and 1 or -1) * 400 * sim_dt * 2))
    end
    replay.record(game.rec, (left and 1 or 0) + (right and 2 or 0))

    local events = spawner.update(sim_dt)
    for _, ev in ipairs(events) do
      if ev.type == "enemy_escaped" and world.enemy_gives_points and not world.no_penalty then
        game.score = math.max(0, game.score - world.enemy_escape_penalty)
        local popup_y = world.fall_direction == 1 and 560 or 60
        ui.addPopup(ev.x, popup_y, "-" .. world.enemy_escape_penalty, COLOR_RED)
      end
    end

    for _, hit in ipairs(spawner.collectHits(player)) do
      if hit.kind == spawner.PICKUP then
        apply_pickup(hit.pickup)
      elseif hit.kind == spawner.FOOD or hit.kind == spawner.GOLD then
        local is_gold = hit.kind == spawner.GOLD
        game.combo = game.combo + 1
        local mult = world.comboMultiplier(game.combo)
        local base = (is_gold and 50 or 10) * (game.effects.double > 0 and 2 or 1)
        local points = base * mult * world.score_mul
        game.score = game.score + points
        game.food_count = game.food_count + 1
        if is_gold then
          game.gold_caught = game.gold_caught + 1
        end
        if game.combo > game.combo_best then
          game.combo_best = game.combo
        end
        player.impact = 0.5
        rulemanager.timer = rulemanager.timer + (world.time_bonus or 0)
        if game.mode.id == "bossrush" and game.boss.active and boss.hit(game.boss) then
          game.bosses_defeated = game.bosses_defeated + 1
          ui.addPopup(400, 200, "BOS KALAH!", theme.yellow)
          sfx.play("record")
        end
        ui.addPopup(hit.x, hit.y, "+" .. points, is_gold and theme.yellow or COLOR_GREEN)
        particles.burst(
          hit.x,
          hit.y,
          is_gold and 1 or COLOR_GREEN[1],
          is_gold and 0.86 or COLOR_GREEN[2],
          is_gold and 0.25 or COLOR_GREEN[3],
          is_gold and 20 or 14
        )
        sfx.play("catch", is_gold and 1.6 or (0.9 + 0.12 * mult))
        if game.combo % (world.combo_step or 4) == 0 then
          ui.addPopup(400, 340, "COMBO x" .. mult, COLOR_ORANGE)
          sfx.play("record", 1.3 + 0.1 * mult)
        end
      else
        handle_enemy(hit)
      end
    end

    if game.mode.id == "bossrush" then
      boss.update(game.boss, world.elapsed, function()
        ui.showBanner("BOS MUNCUL", "Tangkap " .. boss.HP .. " makanan untuk mengalahkan bos")
        sfx.play("swap", 0.6)
      end)
    end

    if world.elapsed >= 120 and rulemanager.max_active < 2 then
      rulemanager.max_active = 2
      ui.showBanner("DUA ATURAN")
      sfx.play("swap", 0.65)
      particles.burst(400, 300, theme.yellow[1], theme.yellow[2], theme.yellow[3], 24)
    end

    game.coins = math.floor(game.score / 25)
    if game.coins >= 20 and game.mode_time % 30 < 0.02 and not game.show_shop then
      game.show_shop = true
      ui.screen = "shop"
      ui.selection = 1
    end
  end

  game.flash = math.max(0, game.flash - dt * 1.8)
  ui.update(dt)
  particles.update(dt)
  if game.debug_overlay then
    debugpanel.update(dt)
  end
end

local function menu_enter(screen)
  ui.screen = screen
  ui.selection = 1
  sfx.play("select")
end

function game.keypressed(key)
  if ui.screen == "shop" then
    if key == "escape" then
      ui.screen = nil
      game.show_shop = false
    elseif key == "up" then
      ui.selection = math.max(1, ui.selection - 1)
    elseif key == "down" then
      ui.selection = math.min(#shop.items, ui.selection + 1)
    elseif key == "return" then
      local item = shop.items[ui.selection]
      if item and game.profile.coins >= item.cost then
        game.profile.coins = game.profile.coins - item.cost
        game.purchases = game.purchases + 1
        if item.id == "heal" then
          game.lives = game.lives + 1
        elseif item.id == "shield" then
          game.effects.shield = 12
        elseif item.id == "magnet" then
          game.effects.magnet = 8
        elseif item.id == "double" then
          game.effects.double = 10
        elseif item.id == "life_max" then
          game.lives = game.lives + 1
        elseif item.id == "reroll" then
          rulemanager.begin_swap(game.ctx)
        end
        progression.save(game.profile_slot, game.profile)
        ui.screen = nil
        game.show_shop = false
        sfx.play("record")
      else
        sfx.play("hit", 0.6)
      end
    end
    return
  end

  if ui.screen then
    if key == "escape" then
      if ui.screen == "settings" then
        settings.save(game.settings)
      end
      if ui.screen == "profiles" then
        game.profile_slot = ui.selection
        game.profile = game.profiles[game.profile_slot]
      end
      ui.screen = nil
      sfx.play("select")
      return
    end
    if ui.screen == "modes" then
      if key == "up" then
        ui.selection = math.max(1, ui.selection - 1)
      elseif key == "down" then
        ui.selection = math.min(modes.count(), ui.selection + 1)
      elseif key == "return" then
        game.startRun(modes.list[ui.selection].id)
      end
    elseif ui.screen == "settings" then
      local n = ui.setting_count()
      if key == "up" then
        ui.selection = math.max(1, ui.selection - 1)
      elseif key == "down" then
        ui.selection = math.min(n, ui.selection + 1)
      elseif key == "left" or key == "right" then
        local k = ui.setting_key(ui.selection)
        local step = (k == "colorblind" or k == "reduced_motion") and 1 or 0.1
        local delta = key == "right" and step or -step
        game.settings[k] = math.max(0, math.min(k == "colorblind" and 1 or 1, (game.settings[k] or 0) + delta))
        game.apply_settings()
      end
    elseif ui.screen == "codex" then
      if key == "up" then
        ui.selection = math.max(1, ui.selection - 1)
      elseif key == "down" then
        ui.selection = math.min(#game.codex_entries, ui.selection + 1)
      end
    elseif ui.screen == "profiles" then
      if key == "up" then
        ui.selection = math.max(1, ui.selection - 1)
      elseif key == "down" then
        ui.selection = math.min(3, ui.selection + 1)
      end
    elseif ui.screen == "replay" then
      if key == "return" then
        rng.set_seed(game.rec.seed)
        game.startRun(game.rec.mode)
      end
    end
    return
  end

  if rulemanager.pending then
    local index = tonumber(key)
    if index and index >= 1 and index <= 3 then
      rulemanager.choose(game.ctx, index)
      sfx.play("select")
    end
    return
  end

  if game.state == "menu" then
    if key == "tab" then
      ui.show_stats = not ui.show_stats
      sfx.play("select")
    elseif ui.show_stats then
      if key == "escape" then
        ui.show_stats = false
      end
    elseif key == "return" or key == "kpenter" or key == "space" then
      sfx.play("select")
      game.startRun(game.mode.id)
    elseif key == "m" then
      game.setMute(not game.muted)
    elseif key == "f1" then
      menu_enter("modes")
    elseif key == "f2" then
      menu_enter("settings")
    elseif key == "f3" then
      menu_enter("codex")
    elseif key == "f4" then
      menu_enter("achievements")
    elseif key == "f5" then
      menu_enter("profiles")
    elseif key == "f6" then
      menu_enter("replay")
    elseif key == "f7" then
      if game.export_profile() then
        ui.addPopup(400, 520, "PROFIL DIEKSPOR", theme.yellow)
      end
    elseif key == "f8" then
      if game.import_profile() then
        ui.addPopup(400, 520, "PROFIL DIIMPOR", theme.yellow)
      end
    elseif key == "escape" then
      love.event.quit()
    end
  elseif game.state == "playing" then
    if key == "p" then
      game.paused = not game.paused
      if game.paused then
        music.stop()
      else
        music.play(game.ctx)
      end
      sfx.play("select")
    elseif key == "lshift" or key == "rshift" then
      if abilities.try_dash(game.ab) then
        game.dashes = game.dashes + 1
        sfx.play("catch", 1.8)
      end
    elseif key == "m" then
      game.setMute(not game.muted)
      if not game.muted then
        music.play(game.ctx)
      end
    elseif key == "i" and game.debug_overlay then
      debugpanel.toggle()
    elseif game.paused and key == "r" then
      game.startRun(game.mode.id)
    elseif game.paused and key == "q" then
      music.stop()
      game.state = "menu"
    elseif key == "escape" then
      music.stop()
      game.state = "menu"
    end
  elseif game.state == "gameover" then
    if key == "return" or key == "kpenter" or key == "space" then
      sfx.play("select")
      game.startRun(game.mode.id)
    elseif key == "m" then
      game.setMute(not game.muted)
    elseif key == "escape" then
      game.state = "menu"
    end
  end
end

function game.resize() end

function game.draw()
  local ww, wh = love.graphics.getDimensions()
  local scale = math.min(ww / 800, wh / 600)
  local ox, oy = (ww - 800 * scale) / 2, (wh - 600 * scale) / 2
  love.graphics.setColor(0.008, 0.010, 0.018, 1)
  love.graphics.rectangle("fill", 0, 0, ww, wh)
  love.graphics.setScissor(ox, oy, 800 * scale, 600 * scale)
  love.graphics.push()
  love.graphics.translate(ox, oy)
  love.graphics.scale(scale, scale)

  if game.trauma > 0 and (game.settings.reduced_motion or 0) == 0 then
    local shake = game.trauma * game.trauma
    local t = game.shake_t
    love.graphics.translate(26 * shake * math.sin(t * 1.1), 20 * shake * math.sin(t * 1.7))
  end

  ui.drawArenaBackground()
  if game.state ~= "menu" then
    local name = rulemanager.activeName()
    if name == "HANTU" then
      love.graphics.setColor(0.1, 0.3, 0.6, 0.08)
    elseif name == "LAYAR GELAP" then
      love.graphics.setColor(0, 0, 0, 0.2)
    elseif name == "HUJAN EMAS" then
      love.graphics.setColor(1, 0.8, 0.2, 0.06)
    else
      love.graphics.setColor(0, 0, 0, 0)
    end
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setColor(1, 1, 1, 1)
  end
  if game.state == "menu" then
    ui.drawMenu(game.highscore, game.time, world.comboMultiplier(game.best_combo_ever), game.games_count)
    ui.drawMenuHint("F1 mode   F2 setting   F3 codex   F4 pencapaian   F5 profil   F6 replay   F7/F8 ekspor/import")
    if ui.show_stats then
      ui.drawStatsOverlay(
        game.highscore,
        world.comboMultiplier(game.best_combo_ever),
        game.stats,
        game.games_count,
        game.top_scores
      )
    end
  else
    spawner.draw()
    player.draw()
    if game.rec.ghost and game.rec.ghost.visible then
      love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.35)
      love.graphics.rectangle("fill", game.rec.ghost.x, game.rec.ghost.y, 40, 40, 6, 6)
      love.graphics.setColor(1, 1, 1, 1)
    end
    particles.draw()
    rulemanager.draw(game.ctx)
    ui.drawPopups()

    if game.flash > 0 then
      love.graphics.setColor(1, 0.18, 0.24, game.flash * 0.35)
      love.graphics.rectangle("fill", -40, -40, 880, 680)
      love.graphics.setColor(1, 1, 1, 1)
    end

    ui.drawHUD(
      math.floor(game.display_score),
      game.lives,
      rulemanager.activeName(),
      rulemanager.timer,
      rulemanager.rule_duration,
      game.run_time,
      world.elapsed >= 120,
      world.comboMultiplier(game.combo),
      game.muted
    )

    if game.mode.time_limit > 0 then
      love.graphics.setFont(ui.FONTS and ui.FONTS.small or love.graphics.newFont(13))
      love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
      love.graphics.printf(
        string.format("%02d", math.max(0, math.ceil(game.mode.time_limit - game.mode_time))),
        300,
        14,
        200,
        "center"
      )
    end

    if game.boss.active then
      love.graphics.setFont(love.graphics.newFont(16))
      love.graphics.setColor(theme.red[1], theme.red[2], theme.red[3], 1)
      love.graphics.printf("BOS  " .. game.boss.hp .. "/" .. boss.HP, 200, 548, 400, "center")
    end

    if game.state == "gameover" then
      ui.drawGameOver(
        game.score,
        game.highscore,
        game.new_record,
        game.time,
        game.run_time,
        world.comboMultiplier(math.max(game.combo_best, game.best_combo_ever))
      )
    elseif game.paused then
      ui.drawPaused()
    end
  end

  ui.drawBanner()
  if ui.draft then
    ui.drawDraft(ui.draft)
  end

  if ui.screen == "modes" then
    ui.drawModeSelect(modes, ui.selection)
  elseif ui.screen == "settings" then
    ui.drawSettings(game.settings, ui.selection)
  elseif ui.screen == "codex" then
    ui.drawCodex(game.codex_entries, ui.selection)
  elseif ui.screen == "achievements" then
    ui.drawAchievements(game.profile, achievements.list)
  elseif ui.screen == "profiles" then
    ui.drawProfiles(game.profiles, game.profile_slot, game.profile)
  elseif ui.screen == "replay" then
    ui.drawReplay(game.rec, #game.rec.frames)
  elseif ui.screen == "shop" then
    ui.drawShop(shop.items, game.profile.coins, ui.selection)
  end

  love.graphics.pop()
  love.graphics.setScissor()
  love.graphics.setColor(1, 1, 1, 1)
  if game.debug_overlay then
    debugpanel.draw()
  end
end

return game
