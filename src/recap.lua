-- src/recap.lua
-- Post-game recap: grade, score over time, combo peak and rule list.

local recap = {}

function recap.new()
  return { samples = {}, grade = "D", rules = {}, peak = 0 }
end

function recap.begin(r)
  r.samples = {}
  r.grade = "D"
  r.rules = {}
  r.peak = 0
end

function recap.sample(r, score, time)
  table.insert(r.samples, { score = score, time = time })
  if #r.samples > 1200 then
    table.remove(r.samples, 1)
  end
end

function recap.finish(r, score, survived, combo, rules)
  local design = require("src.design")
  r.grade = design.grade(score, survived, combo)
  r.peak = combo
  r.rules = {}
  for name in pairs(rules or {}) do
    table.insert(r.rules, name)
  end
  table.sort(r.rules)
  return r
end

function recap.draw(r, font)
  local design = require("src.design")
  love.graphics.setFont(font or love.graphics.newFont(16))
  local c = design.grade_colors[r.grade] or design.neutral[8]
  love.graphics.setColor(c[1], c[2], c[3], 1)
  love.graphics.printf("GRADE  " .. r.grade, 200, 120, 400, "center")
  love.graphics.setColor(0.62, 0.66, 0.75, 1)
  love.graphics.printf("COMBO PUNCAK  " .. r.peak, 200, 152, 400, "center")
  love.graphics.printf("ATURAN DILIHAT  " .. #r.rules, 200, 180, 400, "center")
  -- score graph
  love.graphics.setColor(design.semantic.info[1], design.semantic.info[2], design.semantic.info[3], 1)
  local n = #r.samples
  if n > 1 then
    local max_score = 1
    for _, s in ipairs(r.samples) do
      max_score = math.max(max_score, s.score)
    end
    local last_x, last_y = 160, 320
    for i, s in ipairs(r.samples) do
      local x = 160 + (i - 1) / (n - 1) * 480
      local y = 320 - s.score / max_score * 90
      love.graphics.line(last_x, last_y, x, y)
      last_x, last_y = x, y
    end
  else
    love.graphics.printf("Belum ada data grafik", 200, 270, 400, "center")
  end
  love.graphics.setColor(1, 1, 1, 1)
end

recap.new_state = recap.new

return recap
