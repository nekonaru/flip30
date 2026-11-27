-- src/bosspatterns.lua
-- Five boss encounters with distinct attack patterns.

local patterns = {}

patterns.list = {
  { id = 1, name = "PENJAGA", hp = 10, speed = 0.8, burst = 1, color = "red", hint = "Bos pertama" },
  {
    id = 2,
    name = "PEMBELAH",
    hp = 14,
    speed = 1.1,
    burst = 2,
    splits = true,
    color = "pink",
    hint = "Memecah saat kalah",
  },
  {
    id = 3,
    name = "BAYANGAN",
    hp = 16,
    speed = 1.4,
    burst = 2,
    alpha = 0.5,
    color = "cyan",
    hint = "Setengah transparan",
  },
  {
    id = 4,
    name = "ZIRAH",
    hp = 22,
    speed = 0.6,
    burst = 3,
    armor = true,
    color = "panel_line",
    hint = "Butuh 2 serangan",
  },
  {
    id = 5,
    name = "RAJA FLIP",
    hp = 30,
    speed = 1.6,
    burst = 3,
    splits = true,
    color = "yellow",
    hint = "Bos terakhir",
  },
}

function patterns.get(id)
  return patterns.list[math.max(1, math.min(#patterns.list, id or 1))]
end

function patterns.count()
  return #patterns.list
end

return patterns
