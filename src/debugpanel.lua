-- src/debugpanel.lua
-- Tiny on-screen devtools overlay, enabled with `love . --debug`.
-- Press I to toggle. Shows FPS, object count, draw calls and memory.

local spawner = require("src.spawner")

local debugpanel = {}

debugpanel.visible = false
debugpanel.font = nil

function debugpanel.toggle()
  debugpanel.visible = not debugpanel.visible
end

function debugpanel.update()
  -- reserved for future rolling averages
end

function debugpanel.draw()
  if not debugpanel.visible then
    return
  end
  debugpanel.font = debugpanel.font or love.graphics.newFont(11)
  local stats = love.graphics.getStats()
  local lines = {
    "DEBUG  (I: off)",
    string.format("FPS         %d", love.timer.getFPS()),
    string.format("draw calls  %d", stats.drawcalls),
    string.format("canvas sw.  %d", stats.canvasswitches),
    string.format("objects     %d", #spawner.objects),
    string.format("texture mem %d KB", math.floor(stats.texturememory / 1024)),
  }
  local line_h = 13
  local box_w, box_h = 160, line_h * #lines + 8
  love.graphics.push()
  love.graphics.translate(6, 600 - box_h - 6)
  love.graphics.setColor(0.01, 0.012, 0.02, 0.82)
  love.graphics.rectangle("fill", 0, 0, box_w, box_h, 4, 4)
  love.graphics.setFont(debugpanel.font)
  for i, line in ipairs(lines) do
    if i == 1 then
      love.graphics.setColor(0.12, 0.78, 0.94, 1)
    else
      love.graphics.setColor(0.85, 0.90, 0.98, 1)
    end
    love.graphics.print(line, 8, 6 + (i - 1) * line_h)
  end
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
end

return debugpanel
