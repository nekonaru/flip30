-- src/campaign.lua
-- Eight-chapter story campaign. Each chapter has a goal and rule modifiers.

local campaign = {}

campaign.chapters = {
  { id = 1, name = "PEMULA", hint = "Capai 100 poin", goal = 100, time = 0, rules = 1, enemy = 0.3 },
  { id = 2, name = "HARI PERTAMA", hint = "Capai 200 poin", goal = 200, time = 90, rules = 1, enemy = 0.35 },
  {
    id = 3,
    name = "GELAP",
    hint = "Bertahan 60 detik",
    goal = 0,
    time = 60,
    rules = 2,
    enemy = 0.4,
    force = "LAYAR GELAP",
  },
  {
    id = 4,
    name = "KECEPATAN",
    hint = "Capai 300 poin",
    goal = 300,
    time = 0,
    rules = 2,
    enemy = 0.45,
    force = "SEMUA 2X CEPAT",
  },
  { id = 5, name = "BOS PERTAMA", hint = "Kalahkan bos", goal = 0, time = 0, rules = 1, enemy = 0.3, boss = 1 },
  { id = 6, name = "CHAOS", hint = "Capai 500 poin", goal = 500, time = 120, rules = 3, enemy = 0.5 },
  {
    id = 7,
    name = "DUA ARAH",
    hint = "Bertahan 120 detik",
    goal = 0,
    time = 120,
    rules = 2,
    enemy = 0.45,
    force = "GRAVITASI NAIK",
  },
  { id = 8, name = "FLIP30", hint = "Capai 1000 poin", goal = 1000, time = 0, rules = 3, enemy = 0.55, boss = 5 },
}

function campaign.get(index)
  return campaign.chapters[math.max(1, math.min(#campaign.chapters, index or 1))]
end

function campaign.complete(chapter, score, survived, bosses)
  if chapter.goal > 0 and score < chapter.goal then
    return false
  end
  if chapter.time > 0 and survived < chapter.time and chapter.goal == 0 then
    return false
  end
  if chapter.boss and bosses < chapter.boss then
    return false
  end
  return true
end

function campaign.count()
  return #campaign.chapters
end

return campaign
