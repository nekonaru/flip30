-- src/cosmetics.lua
-- Eight player skins with distinct colours and symbols.

local cosmetics = {}

cosmetics.list = {
  { id = 1, name = "KUNING", color = "yellow", level = 1, symbol = "note" },
  { id = 2, name = "CYAN", color = "cyan", level = 2, symbol = "circle" },
  { id = 3, name = "MERAH", color = "red", level = 3, symbol = "triangle" },
  { id = 4, name = "HIJAU", color = "green", level = 4, symbol = "diamond" },
  { id = 5, name = "UNGU", color = "pink", level = 5, symbol = "star" },
  { id = 6, name = "ORANYE", color = "orange", level = 6, symbol = "bolt" },
  { id = 7, name = "PUTIH", color = "text", level = 7, symbol = "square" },
  { id = 8, name = "EMAS", color = "gold", level = 8, symbol = "crown" },
}

function cosmetics.get(id)
  return cosmetics.list[math.max(1, math.min(#cosmetics.list, id or 1))]
end

function cosmetics.unlocked(level, id)
  return cosmetics.get(id).level <= level
end

return cosmetics
