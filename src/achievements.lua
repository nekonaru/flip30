-- src/achievements.lua
-- 20 achievements checked against a run summary and profile stats.

local achievements = {}

achievements.list = {
  {
    id = "first_run",
    name = "MULAI",
    hint = "Selesaikan 1 sesi",
    check = function(s)
      return s.runs >= 1
    end,
  },
  {
    id = "score_100",
    name = "SERATUS",
    hint = "Capai skor 100",
    check = function(s)
      return s.best >= 100
    end,
  },
  {
    id = "score_500",
    name = "LIMA RATUS",
    hint = "Capai skor 500",
    check = function(s)
      return s.best >= 500
    end,
  },
  {
    id = "score_1000",
    name = "SERIBU",
    hint = "Capai skor 1000",
    check = function(s)
      return s.best >= 1000
    end,
  },
  {
    id = "combo_4",
    name = "RANTAI",
    hint = "Combo x2",
    check = function(s)
      return s.combo >= 4
    end,
  },
  {
    id = "combo_12",
    name = "RANTAI PANJANG",
    hint = "Combo x4",
    check = function(s)
      return s.combo >= 12
    end,
  },
  {
    id = "survive_60",
    name = "MENIT PERTAMA",
    hint = "Bertahan 60 detik",
    check = function(s)
      return s.time >= 60
    end,
  },
  {
    id = "survive_180",
    name = "TIGA MENIT",
    hint = "Bertahan 180 detik",
    check = function(s)
      return s.time >= 180
    end,
  },
  {
    id = "gold_10",
    name = "PEMBuru EMAS",
    hint = "Tangkap 10 emas",
    check = function(s)
      return s.gold >= 10
    end,
  },
  {
    id = "rules_5",
    name = "PENGUMPUL ATURAN",
    hint = "Lihat 5 aturan",
    check = function(s)
      return s.rules_seen >= 5
    end,
  },
  {
    id = "rules_15",
    name = "ARSIPARIS",
    hint = "Lihat 15 aturan",
    check = function(s)
      return s.rules_seen >= 15
    end,
  },
  {
    id = "mods_1",
    name = "MODDER",
    hint = "Pasang 1 mod",
    check = function(s)
      return s.mods >= 1
    end,
  },
  {
    id = "blitz_win",
    name = "SPRINTER",
    hint = "Main BLITZ",
    check = function(s)
      return (s.modes.blitz or 0) >= 1
    end,
  },
  {
    id = "zen_win",
    name = "MEDITASI",
    hint = "Main ZEN",
    check = function(s)
      return (s.modes.zen or 0) >= 1
    end,
  },
  {
    id = "chaos_win",
    name = "KACAU",
    hint = "Main CHAOS",
    check = function(s)
      return (s.modes.chaos or 0) >= 1
    end,
  },
  {
    id = "daily_win",
    name = "HARI INI",
    hint = "Main HARIAN",
    check = function(s)
      return (s.modes.daily or 0) >= 1
    end,
  },
  {
    id = "boss_win",
    name = "PEMBASMI",
    hint = "Kalahkan 1 bos",
    check = function(s)
      return s.bosses >= 1
    end,
  },
  {
    id = "shield_use",
    name = "PERISAI",
    hint = "Gunakan shield",
    check = function(s)
      return s.shields >= 1
    end,
  },
  {
    id = "dash_use",
    name = "LARI",
    hint = "Gunakan dash",
    check = function(s)
      return s.dashes >= 1
    end,
  },
  {
    id = "shop_use",
    name = "PEMBELANJA",
    hint = "Beli di toko",
    check = function(s)
      return s.purchases >= 1
    end,
  },
}

function achievements.check_all(t, summary)
  local unlocked = {}
  for _, a in ipairs(achievements.list) do
    if not t.achievements[a.id] and a.check(summary) then
      t.achievements[a.id] = true
      table.insert(unlocked, a)
    end
  end
  return unlocked
end

function achievements.count(t)
  local n = 0
  for _ in pairs(t.achievements or {}) do
    n = n + 1
  end
  return n
end

return achievements
