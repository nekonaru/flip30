-- Flip30: entry point.
-- All game logic lives in src/. This file only wires LÖVE callbacks to the
-- game module and handles the developer-only `--screenshot` mode used to
-- regenerate README artwork deterministically:
--
--   love . --screenshot shot.png --frames 480
--
-- `--screenshot PATH` captures the window after the given number of simulated
-- fixed-dt frames (default 0, i.e. the very first frame). The simulation is
-- seeded so repeated runs produce identical screenshots.

local game = require("src.game")

local screenshot_path = nil
local screenshot_frames = 0
local force_rule = nil
local force_stats = false
local debug_overlay = false

local function parse_args(arg)
  for i = 1, #(arg or {}) do
    if arg[i] == "--screenshot" then
      screenshot_path = arg[i + 1]
    elseif arg[i] == "--frames" then
      screenshot_frames = tonumber(arg[i + 1]) or 0
    elseif arg[i] == "--force-rule" then
      force_rule = arg[i + 1]
    elseif arg[i] == "--force-stats" then
      force_stats = true
    elseif arg[i] == "--debug" then
      debug_overlay = true
    end
  end
end

function love.load(arg)
  parse_args(arg)
  if screenshot_path then
    -- Fail fast instead of hanging on the blue error screen
    function love.errorhandler(msg)
      print("ERROR: " .. tostring(msg) .. "\n" .. debug.traceback("", 2))
      os.exit(1)
    end
    math.randomseed(20261115) -- deterministic artwork
  else
    math.randomseed(os.time() + love.timer.getTime() * 1000)
  end

  game.load()

  if screenshot_path and screenshot_frames > 0 then
    game.startRun() -- autoplay so artwork shows real gameplay
  end

  if force_rule then
    local rulemanager = require("src.rulemanager")
    local ctx = game.ctx
    for _, rule in ipairs(rulemanager.rules) do
      if rule.name == force_rule then
        rulemanager.revertAll(ctx)
        local ok, err = pcall(rule.apply, ctx)
        if ok then
          rulemanager.active = { rule }
          rulemanager.last_name = rule.name
        else
          print("[force-rule] apply failed for '" .. rule.name .. "': " .. tostring(err))
        end
        break
      end
    end
  end

  if force_stats then
    require("src.ui").show_stats = true
  end

  game.debug_overlay = debug_overlay
  if debug_overlay then
    require("src.debugpanel").visible = true
  end

  for _ = 1, screenshot_frames do
    game.update(1 / 60)
  end
end

function love.update(dt)
  game.update(dt)
end

function love.draw()
  game.draw()

  if screenshot_path then
    local path = screenshot_path
    screenshot_path = nil -- capture once
    if not path:lower():match("%.png$") then
      path = path .. ".png"
    end
    love.graphics.captureScreenshot(function(imagedata)
      local ok, png = pcall(imagedata.encode, imagedata, "png")
      if ok and png then
        local file = io.open(path, "wb")
        if file then
          file:write(png:getString())
          file:close()
          print("[screenshot] wrote " .. path)
        else
          print("[screenshot] could not open " .. path .. " for writing")
        end
      else
        print("[screenshot] failed to encode png: " .. tostring(png))
      end
      love.event.quit()
    end)
  end
end

function love.keypressed(key)
  game.keypressed(key)
end

function love.resize(width, height)
  game.resize(width, height)
end
