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
}

local COLOR_GREEN = { 0.239, 0.859, 0.541 }
local COLOR_RED = { 1.000, 0.302, 0.361 }
local COLOR_ORANGE = { 1.000, 0.576, 0.169 }

function game.load()
  ui.load()
  ui.version = "1.1.0"
  game.highscore = storage.load()
  game.time = 0
  game.ctx = { player = player, world = world, spawner = spawner, ui = ui, sfx = sfx }
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

function game.startRun()
  rulemanager.resetToDefaults(game.ctx)
  rulemanager.max_active = 1 -- escalation to 2 rules happens at the two-minute mark
  spawner.reset()
  game.score = 0
  game.lives = 3
  game.new_record = false
  game.run_time = 0
  game.paused = false
  game.trauma = 0
  game.shake_t = 0
  game.hit_stop = 0
  game.flash = 0
  game.state = "playing"
end

function game.gameOver()
  game.state = "gameover"
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
    player.update(sim_dt, left, right, world.speed_mul)

    local events = spawner.update(sim_dt)
    for _, ev in ipairs(events) do
      if ev.type == "enemy_escaped" and world.enemy_gives_points then
        game.score = math.max(0, game.score - world.enemy_escape_penalty)
        ui.addPopup(ev.x, 560, "-" .. world.enemy_escape_penalty, COLOR_RED)
      end
    end

    local hits = spawner.collectHits(player)
    for _, hit in ipairs(hits) do
      if hit.kind == spawner.FOOD then
        game.score = game.score + 10
        player.impact = 0.5
        ui.addPopup(hit.x, hit.y, "+10", COLOR_GREEN)
        particles.burst(hit.x, hit.y, COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3], 14)
        sfx.play("catch")
      else
        if world.enemy_gives_points then
          game.score = game.score + world.enemy_points
          player.impact = 0.8
          ui.addPopup(hit.x, hit.y, "+" .. world.enemy_points, COLOR_ORANGE)
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

    game.flash = math.max(0, game.flash - dt * 1.8)
  end

  ui.update(dt)
  particles.update(dt)
end

function game.keypressed(key)
  if game.state == "menu" then
    if key == "return" or key == "kpenter" or key == "space" then
      sfx.play("select")
      game.startRun()
    elseif key == "escape" then
      love.event.quit()
    end
  elseif game.state == "playing" then
    if key == "p" then
      game.paused = not game.paused
      sfx.play("select")
    elseif key == "escape" then
      game.state = "menu"
    end
  elseif game.state == "gameover" then
    if key == "return" or key == "kpenter" or key == "space" then
      sfx.play("select")
      game.startRun()
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
    ui.drawMenu(game.highscore, game.time)
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
      game.score,
      game.lives,
      rulemanager.activeName(),
      rulemanager.timer,
      rulemanager.rule_duration,
      game.run_time,
      world.elapsed >= 120
    )

    if game.state == "gameover" then
      ui.drawGameOver(game.score, game.highscore, game.new_record, game.time, game.run_time)
    elseif game.paused then
      ui.drawPaused()
    end
  end

  ui.drawBanner()

  love.graphics.pop()
  love.graphics.setScissor()
  love.graphics.setColor(1, 1, 1, 1)
end

return game
