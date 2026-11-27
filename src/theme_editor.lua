-- src/theme_editor.lua
-- Player-defined accent colour and HUD preset.

local theme_editor = {}

theme_editor.accents = {
  { name = "CYAN", color = { 0.122, 0.780, 0.937 } },
  { name = "KUNING", color = { 1.000, 0.824, 0.247 } },
  { name = "PINK", color = { 1.000, 0.243, 0.541 } },
  { name = "HIJAU", color = { 0.239, 0.859, 0.541 } },
  { name = "ORANYE", color = { 1.000, 0.576, 0.169 } },
  { name = "UNGU", color = { 0.62, 0.45, 0.95 } },
}

theme_editor.presets = { "CLASSIC", "COMPACT", "MINIMAL" }

theme_editor.state = { accent = 1, preset = 1 }

function theme_editor.current()
  return theme_editor.accents[theme_editor.state.accent], theme_editor.presets[theme_editor.state.preset]
end

return theme_editor
