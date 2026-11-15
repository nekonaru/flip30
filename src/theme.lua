-- src/theme.lua
-- Brand-derived design tokens shared by every draw routine.
-- Colors are LÖVE 0..1 floats sampled from the artwork.

local theme = {}

theme.bg_deep = { 0.031, 0.040, 0.070 } -- gradient top edge (#080A12)
theme.bg_base = { 0.075, 0.090, 0.145 } -- gradient bottom edge (#131725)
theme.panel = { 0.066, 0.078, 0.125 } -- chip background
theme.panel_line = { 0.160, 0.195, 0.280 } -- chip outline
theme.cyan = { 0.122, 0.780, 0.937 } -- #1FC7EE
theme.cyan_soft = { 0.122, 0.780, 0.937, 0.85 }
theme.yellow = { 1.000, 0.824, 0.247 } -- #FFD23F
theme.yellow_hi = { 1.000, 0.925, 0.455 }
theme.pink = { 1.000, 0.243, 0.541 } -- #FF3E8A
theme.green = { 0.239, 0.859, 0.541 }
theme.red = { 1.000, 0.302, 0.361 }
theme.orange = { 1.000, 0.576, 0.169 }
theme.text = { 0.925, 0.935, 0.960 }
theme.text_dim = { 0.620, 0.660, 0.750 }
theme.text_mute = { 0.380, 0.410, 0.500 }

function theme.rgba(color, alpha)
  return color[1], color[2], color[3], alpha == nil and (color[4] or 1) or alpha
end

return theme
