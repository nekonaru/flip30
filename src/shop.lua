-- src/shop.lua
-- Between-wave shop. Spend coins on permanent-ish run upgrades.

local shop = {}

shop.items = {
  { id = "heal", name = "TAMBAH NYAWA", cost = 20, hint = "+1 nyawa sekarang" },
  { id = "shield", name = "PERISAI", cost = 15, hint = "Balok 1 musuh" },
  { id = "magnet", name = "MAGNET", cost = 12, hint = "Tarik makanan 8 detik" },
  { id = "double", name = "DOUBLE", cost = 25, hint = "Skor x2 10 detik" },
  { id = "life_max", name = "NYAWA MAKS", cost = 40, hint = "+1 nyawa maksimum" },
  { id = "reroll", name = "GANTI ATURAN", cost = 10, hint = "Ambil aturan baru" },
}

function shop.get(id)
  for _, item in ipairs(shop.items) do
    if item.id == id then
      return item
    end
  end
  return nil
end

return shop
