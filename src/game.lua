-- src/game.lua
-- State machine (menu / playing / gameover) and the main update/draw loop.

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

local game = {
  state = "menu", -- "menu" | "playing" | "gameover"
  score = 0,
  lives = 3,
  highscore = 0,
  new_record = false,
  time = 0,
  run_time = 0, -- seconds survived in the current run (real time)
  paused = false,
  trauma = 0, -- 0..1 screen shake energy, decayed with real time
  shake_t = 0,
  hit_stop = 0, -- seconds of frozen simulation remaining
  flash = 0,
  display_score = 0, -- smooth tally toward the real score
  food_count = 0, -- food caught this run
  combo = 0, -- consecutive catches without touching an enemy
  combo_best = 0, -- best combo of this run
  best_combo_ever = 0, -- persisted best combo across runs
  muted = false,
}

local COLOR_GREEN = { 0.239, 0.859, 0.541 }
local COLOR_RED = { 1.000, 0.302, 0.361 }
local COLOR_ORANGE = { 1.000, 0.576, 0.169 }

function game.setMute(muted)
  game.muted = muted
  sfx.muted = muted
end

function game.load()
  ui.load()
  music.load()
  ui.version = "1.7.0"
  game.highscore = storage.load()
  game.best_combo_ever = storage.loadBestCombo()
  game.games_count = storage.loadGamesCount()
  game.stats = storage.loadStats()
  game.time = 0
  game.ctx = {
    player = player,
    world = world,
    spawner = spawner,
    ui = ui,
    sfx = sfx,
    rulemanager = rulemanager,
    music = music,
  }
  sfx.load()
  particles.load()
  local modloader = require("src.modloader")
  local ok_mods, mods = pcall(modloader.loadMods)
  if ok_mods and #mods > 0 then
    rulemanager.loadRules(mods)
  else
    rulemanager.loadRules()
  end
  rulemanager.resetToDefaults(game.ctx)
  spawner.reset()
end

function game.setMute(muted)
  game.muted = muted
  sfx.muted = muted
  music.muted = muted
end

function game.startRun()
  rulemanager.resetToDefaults(game.ctx)
  rulemanager.max_active = 1 -- escalation to 2 rules happens at the two-minute mark
  spawner.reset()
  music.play(game.ctx)
  game.games_count = game.games_count + 1
  storage.saveGamesCount(game.games_count)
  game.score = 0
  game.display_score = 0
  game.food_count = 0
  game.lives = 3
  game.new_record = false
  game.run_time = 0
  game.combo = 0
  game.combo_best = 0
  game.paused = false
  game.trauma = 0
  game.shake_t = 0
  game.hit_stop = 0
  game.flash = 0
  ui.show_stats = false
  game.state = "playing"
end

function game.gameOver()
  game.state = "gameover"
  music.stop()
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
  if game.score > game.highscore then
    game.highscore = game.score
    game.new_record = true
    storage.save(game.highscore)
    sfx.play("record")
  else
    sfx.play("gameover")
  end
  particles.burst(player.x + player.w / 2, player.y + player.h / 2, 1.000, 0.243, 0.541, 30)
end

local function add_trauma(amount)
  game.trauma = math.min(1, game.trauma + amount)
end

function game.update(dt)
  game.time = game.time + dt

  -- Ease the displayed score toward the real value
  if game.display_score ~= game.score then
    local diff = game.score - game.display_score
    game.display_score = game.display_score + diff * math.min(1, dt * 9)
    if math.abs(diff) < 1 then
      game.display_score = game.score
    end
  end

  if game.paused then
    return -- freeze the world, the banner and the clocks
  end

  local slowmo = ui.bannerActive() and 0.3 or 1
  -- Hit-stop punches the freeze, never below 0.08x real time
  local hitstop = game.hit_stop > 0 and 0.08 or 1
  local sim_dt = dt * slowmo * hitstop
  game.hit_stop = math.max(0, game.hit_stop - dt)
  game.trauma = math.max(0, game.trauma - dt * 1.5)
  game.shake_t = game.shake_t + dt * 42

  if game.state == "playing" then
    game.run_time = game.run_time + dt
    -- Rule timer runs on real time; the simulation runs in slow motion
    -- while a rule banner is on screen.
    rulemanager.update(game.ctx, dt)
    world.update(sim_dt)

    local left = love.keyboard.isDown("a", "left")
    local right = love.keyboard.isDown("d", "right")
    player.update(sim_dt, left, right, world.speed_mul, world.wrap)

    local events = spawner.update(sim_dt)
    for _, ev in ipairs(events) do
      if ev.type == "enemy_escaped" and world.enemy_gives_points then
        game.score = math.max(0, game.score - world.enemy_escape_penalty)
        local popup_y = world.fall_direction == 1 and 560 or 60
        ui.addPopup(ev.x, popup_y, "-" .. world.enemy_escape_penalty, COLOR_RED)
      end
    end

    local hits = spawner.collectHits(player)
    for _, hit in ipairs(hits) do
      if hit.kind == spawner.FOOD or hit.kind == spawner.GOLD then
        local is_gold = hit.kind == spawner.GOLD
        game.combo = game.combo + 1
        local mult = world.comboMultiplier(game.combo)
        local base = is_gold and 50 or 10
        local points = base * mult * world.score_mul
        game.score = game.score + points
        game.food_count = game.food_count + 1
        if game.combo > game.combo_best then
          game.combo_best = game.combo
        end
        player.impact = 0.5
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
        if game.combo == 4 or game.combo == 8 or game.combo == 12 or game.combo == 16 then
          ui.addPopup(400, 340, "COMBO x" .. mult, COLOR_ORANGE)
          sfx.play("record", 1.3 + 0.1 * mult)
        end
      else
        game.combo = 0
        if world.enemy_gives_points then
          local points = world.enemy_points * world.score_mul
          game.score = game.score + points
          player.impact = 0.8
          ui.addPopup(hit.x, hit.y, "+" .. points, COLOR_ORANGE)
          particles.burst(hit.x, hit.y, COLOR_ORANGE[1], COLOR_ORANGE[2], COLOR_ORANGE[3], 14)
          sfx.play("catch")
        else
          game.lives = math.max(0, game.lives - world.enemy_life_damage)
          add_trauma(0.65)
          game.hit_stop = math.max(game.hit_stop, 0.06)
          game.flash = 0.7
          player.impact = 1.0
          ui.addPopup(hit.x, hit.y, "-1 NYAWA", COLOR_RED)
          particles.burst(hit.x, hit.y, COLOR_RED[1], COLOR_RED[2], COLOR_RED[3], 20)
          sfx.play("hit")
          if game.lives <= 0 then
            game.gameOver()
          end
        end
      end
    end

    -- Two rules at once after the two-minute mark
    if world.elapsed >= 120 and rulemanager.max_active < 2 then
      rulemanager.max_active = 2
      ui.showBanner("DUA ATURAN")
      sfx.play("swap", 0.65)
      particles.burst(400, 300, theme.yellow[1], theme.yellow[2], theme.yellow[3], 24)
    end
  end

  -- The red flash must always decay, including on the game over screen
  game.flash = math.max(0, game.flash - dt * 1.8)

  ui.update(dt)
  particles.update(dt)
  if game.debug_overlay then
    debugpanel.update(dt)
  end
end

function game.keypressed(key)
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
      game.startRun()
    elseif key == "m" then
      game.muted = not game.muted
      sfx.muted = game.muted
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
    elseif key == "m" then
      game.muted = not game.muted
      game.setMute(game.muted)
      if not game.muted then
        music.play(game.ctx)
      end
    elseif key == "i" and game.debug_overlay then
      debugpanel.toggle()
    elseif key == "escape" then
      music.stop()
      game.state = "menu"
    end
  elseif game.state == "gameover" then
    if key == "return" or key == "kpenter" or key == "space" then
      sfx.play("select")
      game.startRun()
    elseif key == "m" then
      game.muted = not game.muted
      game.setMute(game.muted)
    elseif key == "escape" then
      game.state = "menu"
    end
  end
end

function game.resize(_, _)
  -- Letterboxing is computed per-frame from the current window size.
end

function game.draw()
  local ww, wh = love.graphics.getDimensions()
  local scale = math.min(ww / 800, wh / 600)
  local offset_x = (ww - 800 * scale) / 2
  local offset_y = (wh - 600 * scale) / 2

  -- Letterbox bars
  love.graphics.setColor(0.008, 0.010, 0.018, 1)
  love.graphics.rectangle("fill", 0, 0, ww, wh)

  love.graphics.setScissor(offset_x, offset_y, 800 * scale, 600 * scale)
  love.graphics.push()
  love.graphics.translate(offset_x, offset_y)
  love.graphics.scale(scale, scale)

  if game.trauma > 0 then
    local shake = game.trauma * game.trauma
    local t = game.shake_t
    love.graphics.translate(
      26 * shake * math.sin(t * 1.1) + 6 * shake * math.sin(t * 3.7),
      20 * shake * math.sin(t * 1.7) + 6 * shake * math.sin(t * 4.3)
    )
  end

  ui.drawArenaBackground()

  if game.state == "menu" then
    ui.drawMenu(game.highscore, game.time, world.comboMultiplier(game.best_combo_ever), game.games_count)
    if ui.show_stats then
      ui.drawStatsOverlay(game.highscore, game.best_combo_ever, game.stats, game.games_count)
    end
  else
    spawner.draw()
    player.draw()
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

  love.graphics.pop()
  love.graphics.setScissor()
  love.graphics.setColor(1, 1, 1, 1)

  if game.debug_overlay then
    debugpanel.draw()
  end
end

return game
