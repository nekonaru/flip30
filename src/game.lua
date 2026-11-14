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

local game = {
  state = "menu", -- "menu" | "playing" | "gameover"
  score = 0,
  lives = 3,
  highscore = 0,
  new_record = false,
  time = 0,
  shake = 0,
  flash = 0,
}

local ARENA_BG = { 11 / 255, 15 / 255, 26 / 255 } -- matches the brand artwork (#0B0F1A)
local COLOR_RED = { 1.000, 0.302, 0.361 }
local COLOR_GREEN = { 0.239, 0.859, 0.541 }
local COLOR_ORANGE = { 1.000, 0.576, 0.169 }

function game.load()
  ui.load()
  game.highscore = storage.load()
  game.time = 0
  game.ctx = { player = player, world = world, spawner = spawner, ui = ui, sfx = sfx }
  sfx.load()
  particles.load()
  rulemanager.loadRules()
  rulemanager.resetToDefaults(game.ctx)
  spawner.reset()
end

function game.startRun()
  rulemanager.resetToDefaults(game.ctx)
  spawner.reset()
  game.score = 0
  game.lives = 3
  game.new_record = false
  game.shake = 0
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
  particles.burst(player.x + player.w / 2, player.y + player.h / 2, 1.000, 0.243, 0.541, 26)
end

function game.update(dt)
  game.time = game.time + dt
  local slowmo = ui.bannerActive() and 0.3 or 1
  local sim_dt = dt * slowmo

  if game.state == "playing" then
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
        ui.addPopup(hit.x, hit.y, "+10", COLOR_GREEN)
        particles.burst(hit.x, hit.y, COLOR_GREEN[1], COLOR_GREEN[2], COLOR_GREEN[3], 14)
        sfx.play("catch")
      else
        if world.enemy_gives_points then
          game.score = game.score + world.enemy_points
          ui.addPopup(hit.x, hit.y, "+" .. world.enemy_points, COLOR_ORANGE)
          particles.burst(hit.x, hit.y, COLOR_ORANGE[1], COLOR_ORANGE[2], COLOR_ORANGE[3], 14)
          sfx.play("catch")
        else
          game.lives = math.max(0, game.lives - world.enemy_life_damage)
          game.shake = 0.6
          game.flash = 0.7
          ui.addPopup(hit.x, hit.y, "-1 NYAWA", COLOR_RED)
          particles.burst(hit.x, hit.y, COLOR_RED[1], COLOR_RED[2], COLOR_RED[3], 20)
          sfx.play("hit")
          if game.lives <= 0 then
            game.gameOver()
          end
        end
      end
    end

    game.shake = math.max(0, game.shake - dt * 1.4)
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
    if key == "escape" then
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

local function draw_arena_background()
  love.graphics.setColor(ARENA_BG[1], ARENA_BG[2], ARENA_BG[3], 1)
  love.graphics.rectangle("fill", 0, 0, 800, 600)

  -- Faint dot grid for depth
  love.graphics.setColor(1, 1, 1, 0.045)
  for gx = 40, 760, 46 do
    for gy = 40, 560, 46 do
      love.graphics.circle("fill", gx, gy, 1.6)
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function game.draw()
  local ww, wh = love.graphics.getDimensions()
  local scale = math.min(ww / 800, wh / 600)
  local offset_x = (ww - 800 * scale) / 2
  local offset_y = (wh - 600 * scale) / 2

  -- Letterbox bars
  love.graphics.setColor(0.01, 0.012, 0.02, 1)
  love.graphics.rectangle("fill", 0, 0, ww, wh)

  love.graphics.setScissor(offset_x, offset_y, 800 * scale, 600 * scale)
  love.graphics.push()
  love.graphics.translate(offset_x, offset_y)
  love.graphics.scale(scale, scale)

  if game.shake > 0 then
    love.graphics.translate((math.random() - 0.5) * game.shake * 26, (math.random() - 0.5) * game.shake * 26)
  end

  draw_arena_background()

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

    ui.drawHUD(game.score, game.lives, rulemanager.activeName(), rulemanager.timer, rulemanager.rule_duration)

    if game.state == "gameover" then
      ui.drawGameOver(game.score, game.highscore, game.new_record, game.time)
    end
  end

  ui.drawBanner()

  love.graphics.pop()
  love.graphics.setScissor()
  love.graphics.setColor(1, 1, 1, 1)
end

return game
