-- src/pickups.lua
-- Power-ups drop from the sky and apply timed effects when caught.

local pickups = {}

pickups.TYPES = {
  magnet = { name = "MAGNET", duration = 8, color = "cyan", hint = "Tarik makanan" },
  shield = { name = "SHIELD", duration = 12, color = "cyan", hint = "Balok 1 musuh" },
  freeze = { name = "FREEZE", duration = 4, color = "cyan", hint = "Objek berhenti" },
  double = { name = "DOUBLE", duration = 10, color = "yellow", hint = "Skor dikali 2" },
  life = { name = "NYAWA", duration = 0, color = "pink", hint = "Tambah 1 nyawa" },
  skip = { name = "SKIP", duration = 0, color = "orange", hint = "Lewati aturan" },
  clear = { name = "CLEAR", duration = 0, color = "red", hint = "Bersihkan musuh" },
}

local order = { "magnet", "shield", "freeze", "double", "life", "skip", "clear" }

function pickups.pick(chance, rng)
  if chance <= 0 or rng.random() > chance then
    return nil
  end
  return order[rng.random(1, #order)]
end

function pickups.get(id)
  return pickups.TYPES[id]
end

return pickups
