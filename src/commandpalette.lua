-- src/commandpalette.lua
-- Quick actions from a single overlay, opened with the slash key.

local palette = {}

palette.actions = {
  { id = "modes", name = "PILIH MODE", hint = "Buka pilih mode" },
  { id = "settings", name = "PENGATURAN", hint = "Buka pengaturan" },
  { id = "codex", name = "CODEX ATURAN", hint = "Lihat semua aturan" },
  { id = "achievements", name = "PENCAPAIAN", hint = "Lihat pencapaian" },
  { id = "profiles", name = "PROFIL", hint = "Ganti profil" },
  { id = "replay", name = "REPLAY", hint = "Lihat replay" },
  { id = "campaign", name = "KAMPANYE", hint = "Buka kampanye" },
  { id = "theme", name = "TEMA", hint = "Edit warna" },
  { id = "modmanager", name = "MOD MANAGER", hint = "Kelola mod" },
  { id = "recap", name = "REKAP", hint = "Lihat rekap" },
}

function palette.find(id)
  for i, a in ipairs(palette.actions) do
    if a.id == id then
      return a, i
    end
  end
  return nil
end

return palette
