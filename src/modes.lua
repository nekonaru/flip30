-- src/modes.lua
-- Game modes available from the mode-select screen.
-- A mode defines spawn rules, starting rule count, time limits and score style.

local modes = {}

modes.list = {
  {
    id = "classic",
    name = "KLASIK",
    hint = "Aturan berubah tiap 30 detik",
    time_limit = 0,
    start_rules = 1,
    enemy_chance = 0.40,
    spawn_mul = 1,
    score_mul = 1,
    color = "cyan",
  },
  {
    id = "blitz",
    name = "BLITZ",
    hint = "60 detik, skor secepat mungkin",
    time_limit = 60,
    start_rules = 1,
    enemy_chance = 0.35,
    spawn_mul = 1.25,
    score_mul = 1.5,
    color = "yellow",
  },
  {
    id = "marathon",
    name = "MARATHON",
    hint = "Musuh makin ganas seiring waktu",
    time_limit = 0,
    start_rules = 1,
    enemy_chance = 0.50,
    spawn_mul = 1.1,
    score_mul = 1.2,
    color = "orange",
  },
  {
    id = "zen",
    name = "ZEN",
    hint = "Tanpa musuh, santai saja",
    time_limit = 0,
    start_rules = 1,
    enemy_chance = 0,
    spawn_mul = 0.9,
    score_mul = 0.5,
    color = "green",
  },
  {
    id = "chaos",
    name = "CHAOS",
    hint = "Tiga aturan aktif dari awal",
    time_limit = 0,
    start_rules = 3,
    enemy_chance = 0.45,
    spawn_mul = 1.3,
    score_mul = 2,
    color = "pink",
  },
  {
    id = "daily",
    name = "HARIAN",
    hint = "Seed sama untuk semua pemain hari ini",
    time_limit = 0,
    start_rules = 1,
    enemy_chance = 0.4,
    spawn_mul = 1,
    score_mul = 1,
    color = "cyan",
  },
  {
    id = "bossrush",
    name = "BOSS RUSH",
    hint = "Bos tiap 2 menit",
    time_limit = 0,
    start_rules = 1,
    enemy_chance = 0.45,
    spawn_mul = 1,
    score_mul = 1.5,
    color = "red",
  },
}

function modes.get(id)
  for _, mode in ipairs(modes.list) do
    if mode.id == id then
      return mode
    end
  end
  return modes.list[1]
end

function modes.count()
  return #modes.list
end

return modes
