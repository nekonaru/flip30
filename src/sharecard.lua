-- src/sharecard.lua
-- Build a shareable run card as text or PNG caption.

local sharecard = {}

local function world_combo(streak)
  return math.max(1, math.floor(streak / 4) + 1)
end

function sharecard.build(run)
  return {
    title = "FLIP30  " .. (run.mode or "CLASSIC"),
    score = tostring(run.score or 0),
    grade = run.grade or "D",
    time = string.format("%02d:%02d", math.floor((run.time or 0) / 60), math.floor((run.time or 0) % 60)),
    combo = "x" .. tostring(world_combo(run.combo or 0)),
    seed = tostring(run.seed or 0),
  }
end

function sharecard.text(card)
  return table.concat({
    card.title,
    "SKOR " .. card.score .. "   GRADE " .. card.grade,
    "WAKTU " .. card.time .. "   COMBO " .. card.combo,
    "SEED " .. card.seed,
  }, "\n")
end

sharecard.world_combo = world_combo

return sharecard
