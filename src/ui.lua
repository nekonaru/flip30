-- src/ui.lua
-- Immediate-mode style UI helpers: menu, HUD, banner, popups, pause and game over.

local theme = require("src.theme")

local ui = {}

ui.banner = nil -- { text = string, t = number, duration = number, hint = string|nil }
ui.popups = {} -- { x, y, text, color, t }
ui.version = nil
ui.show_stats = false -- TAB toggles the statistics overlay on the menu

local FONTS = {}
local LOGO = nil
local ICON = nil
local BG_GRADIENT = nil
local BG_CANVAS = nil
local draw_arena_static -- forward declaration; assigned below

local function round_rect(mode, x, y, w, h, r)
  love.graphics.rectangle(mode, x, y, w, h, r, r)
end

function ui.load()
  FONTS.small = love.graphics.newFont(13)
  FONTS.body = love.graphics.newFont(19)
  FONTS.big = love.graphics.newFont(40)
  FONTS.huge = love.graphics.newFont(64)

  local ok_logo, logo = pcall(love.graphics.newImage, "assets/brand/logo-main.png")
  if ok_logo then
    LOGO = logo
  end
  local ok_icon, icon = pcall(love.graphics.newImage, "assets/brand/icon-512.png")
  if ok_icon then
    ICON = icon
  end

  -- Pre-render the static arena background once; fallback keeps the game working
  -- even if the GPU refuses the canvas
  local success, err = pcall(function()
    BG_CANVAS = love.graphics.newCanvas(800, 600)
    love.graphics.setCanvas(BG_CANVAS)
    draw_arena_static()
    love.graphics.setCanvas()
  end)
  love.graphics.setCanvas() -- always restore the default framebuffer
  if not success then
    print("[ui] arena background prerender failed: " .. tostring(err))
    BG_CANVAS = nil
  end
end

local function draw_vignette()
  if not BG_GRADIENT then
    local size = 256
    local data = love.image.newImageData(size, size)
    for y = 0, size - 1 do
      for x = 0, size - 1 do
        local dx = (x - size / 2) / (size / 2)
        local dy = (y - size / 2) / (size / 2)
        local dist = math.sqrt(dx * dx + dy * dy)
        local alpha = math.max(0, math.min(1, (dist - 0.55) / 0.45))
        alpha = alpha * alpha * 0.55
        data:setPixel(x, y, 0, 0, 0, alpha)
      end
    end
    BG_GRADIENT = love.graphics.newImage(data)
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(BG_GRADIENT, -0.5, -0.5, 0, 800 / BG_GRADIENT:getWidth(), 600 / BG_GRADIENT:getHeight())
end

draw_arena_static = function()
  -- Vertical gradient, deep navy to slate
  love.graphics.setColor(theme.bg_deep[1], theme.bg_deep[2], theme.bg_deep[3], 1)
  love.graphics.rectangle("fill", 0, 0, 800, 300)
  love.graphics.setColor(theme.bg_base[1], theme.bg_base[2], theme.bg_base[3], 1)
  love.graphics.rectangle("fill", 0, 300, 800, 300)

  -- Faint dot grid for depth
  love.graphics.setColor(1, 1, 1, 0.05)
  for gx = 44, 756, 48 do
    for gy = 44, 556, 48 do
      love.graphics.circle("fill", gx, gy, 1.5)
    end
  end

  draw_vignette()
  love.graphics.setColor(1, 1, 1, 1)
end

function ui.drawArenaBackground()
  if BG_CANVAS then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(BG_CANVAS, 0, 0)
  else
    draw_arena_static()
  end
end

-- ---------------------------------------------------------------- banner

function ui.showBanner(text, hint)
  ui.banner = { text = text, t = 0, duration = 2.0, hint = hint }
end

function ui.bannerActive()
  return ui.banner ~= nil and ui.banner.t < ui.banner.duration
end

local function ease_out_back(p)
  local c1 = 1.70158
  local c3 = c1 + 1
  local q = p - 1
  return 1 + c3 * q * q * q + c1 * q * q
end

function ui.update(dt)
  if ui.banner then
    ui.banner.t = ui.banner.t + dt
    if ui.banner.t >= ui.banner.duration then
      ui.banner = nil
    end
  end
  for i = #ui.popups, 1, -1 do
    local popup = ui.popups[i]
    popup.t = popup.t - dt
    popup.y = popup.y - 46 * dt
    if popup.t <= 0 then
      table.remove(ui.popups, i)
    end
  end
end

function ui.addPopup(x, y, text, color)
  table.insert(ui.popups, { x = x, y = y, text = text, color = color or { 1, 1, 1 }, t = 0.9 })
end

function ui.drawPopups()
  for _, popup in ipairs(ui.popups) do
    local alpha = math.min(1, popup.t / 0.45)
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(0, 0, 0, alpha * 0.8)
    love.graphics.printf(popup.text, popup.x - 78, popup.y + 2, 160, "center")
    love.graphics.setColor(popup.color[1], popup.color[2], popup.color[3], alpha)
    love.graphics.printf(popup.text, popup.x - 80, popup.y, 160, "center")
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function ui.drawBanner()
  if not ui.banner then
    return
  end
  local b = ui.banner
  local p = math.min(1, b.t / b.duration)
  local in_p = math.min(1, p / 0.2)
  local scale = ease_out_back(in_p)
  local alpha = p > 0.72 and math.max(0, 1 - (p - 0.72) / 0.28) or 1

  love.graphics.push()
  love.graphics.translate(400, 205)
  love.graphics.scale(scale, scale)

  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.45 * alpha)
  round_rect("fill", -356, -64, 712, 128, 16)
  love.graphics.setColor(0.03, 0.04, 0.07, 0.92 * alpha)
  round_rect("fill", -348, -56, 696, 112, 13)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.9 * alpha)
  love.graphics.setLineWidth(2.5)
  round_rect("line", -348, -56, 696, 112, 13)
  love.graphics.setLineWidth(1)

  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(0, 0, 0, alpha)
  love.graphics.printf(b.text .. "!", -344, -28 + 3, 696, "center")
  love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], alpha)
  love.graphics.printf(b.text .. "!", -348, -28, 696, "center")

  if b.hint then
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], alpha)
    love.graphics.printf(b.hint, -340, 14, 680, "center")
  end
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
end

-- ------------------------------------------------------------- widgets

local heart_points = nil
local function heartPolygon()
  if heart_points then
    return heart_points
  end
  local points = {}
  for i = 0, 40 do
    local t = (i / 40) * math.pi * 2
    local x = 16 * math.sin(t) ^ 3
    local y = -(13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
    table.insert(points, x * 0.55)
    table.insert(points, y * 0.55)
  end
  heart_points = points
  return heart_points
end

function ui.drawHeart(x, y, scale, r, g, b, a)
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.scale(scale or 1, scale or 1)
  love.graphics.setColor(r or 1, g or 0.24, b or 0.54, a or 1)
  love.graphics.polygon("fill", heartPolygon())
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
end

local function draw_chip(x, y, w, h)
  love.graphics.setColor(theme.panel[1], theme.panel[2], theme.panel[3], 0.92)
  round_rect("fill", x, y, w, h, 10)
  love.graphics.setColor(theme.panel_line[1], theme.panel_line[2], theme.panel_line[3], 0.9)
  love.graphics.setLineWidth(1.5)
  round_rect("line", x, y, w, h, 10)
  love.graphics.setLineWidth(1)
end

-- --------------------------------------------------------------- menu

function ui.drawMenu(highscore, time, best_combo, games_count)
  local t = time or 0
  local pulse = 0.5 + 0.5 * math.sin(t * 1.6)

  -- Ambient drifting silhouettes (food and enemy shapes falling slowly)
  local drift = (t * 34) % 210
  love.graphics.setColor(theme.green[1], theme.green[2], theme.green[3], 0.16)
  for _, x in ipairs({ 120, 330, 520, 690 }) do
    love.graphics.circle("fill", x, (drift * 1.35 + x * 2) % 760 - 60, 12)
  end
  love.graphics.setColor(theme.red[1], theme.red[2], theme.red[3], 0.14)
  for _, x in ipairs({ 190, 430, 610 }) do
    local y = (drift * 1.1 + x * 3) % 760 - 60
    love.graphics.polygon("fill", x, y - 11, x + 11, y + 8, x - 11, y + 8)
  end

  -- Logo: the brand carries its own contrast; no glow behind it
  love.graphics.setColor(1, 1, 1, 1)
  if LOGO then
    local lw = 540
    local scale = lw / LOGO:getWidth()
    love.graphics.draw(LOGO, 400 - lw / 2, 92, 0, scale, scale)
  elseif ICON then
    local s = 210 / ICON:getWidth()
    love.graphics.draw(ICON, 400 - 105, 88, 0, s, s)
  end

  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.printf("Tangkap makanan, hindari musuh, kuasai aturan.", 60, 330, 680, "center")

  -- Primary CTA chip
  local cta_w, cta_h = 320, 58
  local cta_x, cta_y = 400 - cta_w / 2, 372
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.14 + 0.10 * pulse)
  round_rect("fill", cta_x, cta_y, cta_w, cta_h, 12)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.75)
  love.graphics.setLineWidth(2)
  round_rect("line", cta_x, cta_y, cta_w, cta_h, 12)
  love.graphics.setLineWidth(1)
  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.printf("TEKAN  ENTER", cta_x, cta_y + 7, cta_w, "center")

  -- Controls strip
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf(
    "A/D bergerak   ·   P pause   ·   M mute   ·   TAB statistik   ·   ESC keluar",
    40,
    450,
    720,
    "center"
  )

  -- High score chip
  if highscore > 0 then
    local text = "SKOR TERBAIK   " .. tostring(highscore)
    local font_w = FONTS.body:getWidth(text) + 44
    local chip_x = 400 - font_w / 2
    draw_chip(chip_x, 484, font_w, 34)
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
    love.graphics.printf(text, chip_x, 490, font_w, "center")
  end

  if (best_combo or 0) > 1 then
    local text = "COMBO TERBAIK   x" .. tostring(best_combo)
    local font_w = FONTS.small:getWidth(text) + 36
    local chip_x = 400 - font_w / 2
    draw_chip(chip_x, 518, font_w, 26)
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.orange[1], theme.orange[2], theme.orange[3], 1)
    love.graphics.printf(text, chip_x, 523, font_w, "center")
  end

  -- total runs are shown in the stats overlay instead of the footer
  if ui.version then
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 0.85)
    love.graphics.print("FLIP30 v" .. ui.version, 10, 578)
    love.graphics.printf("github.com/nekonaru/flip30", 560, 578, 230, "right")
  end
end

-- ---------------------------------------------------------------- HUD

local function mmss(seconds)
  local m = math.floor(seconds / 60)
  local s = math.floor(seconds % 60)
  return string.format("%02d:%02d", m, s)
end

function ui.drawHUD(score, lives, rule_name, timer, duration, elapsed, double_rules, combo_multi, muted)
  -- Top gradient rule timer strip
  local fraction = duration and duration > 0 and math.max(0, math.min(1, timer / duration)) or 1
  love.graphics.setColor(0.05, 0.06, 0.10, 1)
  love.graphics.rectangle("fill", 0, 0, 800, 6)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.95)
  love.graphics.rectangle("fill", 0, 0, 800 * fraction, 6)

  -- Score chip, top-left
  draw_chip(12, 12, 158, 78)
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.print("SKOR", 24, 16)
  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], 1)
  love.graphics.print(tostring(score), 22, 33)

  -- Lives chip, under the score
  draw_chip(12, 98, 158, 40)
  for i = 1, 3 do
    if i <= lives then
      ui.drawHeart(36 + (i - 1) * 42, 118, 0.9, theme.pink[1], theme.pink[2], theme.pink[3], 1)
    else
      ui.drawHeart(36 + (i - 1) * 42, 118, 0.9, 0.30, 0.30, 0.36, 0.9)
    end
  end

  -- Combo chip, below the hearts, only when the streak pays off
  if (combo_multi or 1) > 1 then
    draw_chip(12, 146, 158, 32)
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.orange[1], theme.orange[2], theme.orange[3], 1)
    love.graphics.printf("COMBO x" .. combo_multi, 12, 156, 158, "center")
  end

  -- Rule pill, top-center
  local rule_text = rule_name or "NORMAL"
  love.graphics.setFont(FONTS.small)
  local pill_w = math.max(150, FONTS.small:getWidth(rule_text) + 78)
  draw_chip(400 - pill_w / 2, 12, pill_w, 30)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.printf(rule_text, 400 - pill_w / 2, 18, pill_w, "center")

  -- Red heartbeat when a single life remains
  if lives == 1 then
    local pulse = 0.05 + 0.07 * math.sin((elapsed or 0) * 5)
    love.graphics.setColor(theme.red[1], theme.red[2], theme.red[3], pulse)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
  end

  -- Timer and difficulty, top-right
  draw_chip(622, 12, 166, 58)
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.print("BERTAHAN", 634, 14)
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], 1)
  love.graphics.print(mmss(elapsed or 0), 634, 27)
  if double_rules then
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
    love.graphics.printf("2x ATURAN", 634, 46, 142, "right")
  end
  if muted then
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.red[1], theme.red[2], theme.red[3], 1)
    love.graphics.printf("MUTE", 634, 46, 142, "left")
  end

  love.graphics.setColor(1, 1, 1, 1)
end

-- -------------------------------------------------------------- pause

function ui.drawPaused()
  love.graphics.setColor(0.01, 0.012, 0.02, 0.68)
  love.graphics.rectangle("fill", 0, 0, 800, 600)

  local panel_w, panel_h = 380, 190
  local px, py = 400 - panel_w / 2, 230 - panel_h / 2
  draw_chip(px, py, panel_w, panel_h)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.8)
  love.graphics.setLineWidth(2)
  round_rect("line", px, py, panel_w, panel_h, 10)
  love.graphics.setLineWidth(1)

  love.graphics.setFont(FONTS.huge)
  love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], 1)
  love.graphics.printf("PAUSED", px, py + 22, panel_w, "center")

  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.printf("P: lanjut bermain", px, py + 92, panel_w, "center")
  love.graphics.printf("R: main lagi   ·   Q / ESC: menu", px, py + 124, panel_w, "center")
  love.graphics.printf("M: bisukan suara", px, py + 156, panel_w, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

-- ---------------------------------------------------------- game over

function ui.drawGameOver(score, highscore, new_record, time, survived, best_combo)
  love.graphics.setColor(0.01, 0.012, 0.02, 0.74)
  love.graphics.rectangle("fill", 0, 0, 800, 600)

  local panel_w, panel_h = 440, 390
  local px, py = 180, 105
  draw_chip(px, py, panel_w, panel_h)
  love.graphics.setColor(theme.pink[1], theme.pink[2], theme.pink[3], 0.8)
  love.graphics.setLineWidth(2.5)
  round_rect("line", px, py, panel_w, panel_h, 10)
  love.graphics.setLineWidth(1)

  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.pink[1], theme.pink[2], theme.pink[3], 1)
  love.graphics.printf("GAME OVER", px, py + 22, panel_w, "center")

  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("SKOR AKHIR", px, py + 84, panel_w / 2, "center")
  love.graphics.printf("BERTAHAN", px + panel_w / 2, py + 84, panel_w / 2, "center")

  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], 1)
  love.graphics.printf(tostring(score), px, py + 102, panel_w / 2, "center")
  love.graphics.printf(mmss(survived or 0), px + panel_w / 2, py + 102, panel_w / 2, "center")

  if new_record then
    local pulse = 0.7 + 0.3 * math.sin((time or 0) * 6)
    love.graphics.setFont(FONTS.big)
    love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], pulse)
    love.graphics.printf("REKOR BARU!", px, py + 172, panel_w, "center")
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
    love.graphics.printf("Skor terbaik: " .. highscore, px, py + 226, panel_w, "center")
  else
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
    love.graphics.printf("TERBAIK: " .. highscore, px, py + 190, panel_w, "center")
  end

  if (best_combo or 0) > 1 then
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(theme.orange[1], theme.orange[2], theme.orange[3], 1)
    love.graphics.printf("COMBO TERBAIK x" .. best_combo, px, py + 258, panel_w, "center")
  end

  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.printf("ENTER: main lagi      ESC: menu", px, py + 326, panel_w, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

-- ---------------------------------------------------------- statistics

local function stat_row(label, value, x, y, w)
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.print(label, x, y)
  love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], 1)
  love.graphics.printf(tostring(value), x, y, w, "right")
end

function ui.drawStatsOverlay(highscore, best_combo, stats, games_count, top_scores)
  stats = stats or { time = 0, score = 0, food = 0 }
  love.graphics.setColor(0.01, 0.012, 0.02, 0.82)
  love.graphics.rectangle("fill", 0, 0, 800, 600)

  local panel_w, panel_h = 560, 330
  local px, py = 120, 135
  draw_chip(px, py, panel_w, panel_h)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.8)
  love.graphics.setLineWidth(2)
  round_rect("line", px, py, panel_w, panel_h, 12)
  love.graphics.setLineWidth(1)

  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.printf("STATISTIK", px, py + 18, panel_w, "center")

  local row_x, row_w = px + 36, 244
  stat_row("TOTAL MAIN", games_count or 0, row_x, py + 84, row_w)
  stat_row("TOTAL WAKTU", mmss(stats.time or 0), row_x, py + 124, row_w)
  stat_row("TOTAL SKOR", stats.score or 0, row_x, py + 164, row_w)
  stat_row("TOTAL MAKANAN", stats.food or 0, row_x, py + 204, row_w)
  stat_row("SKOR TERBAIK", highscore or 0, row_x, py + 244, row_w)
  stat_row("COMBO TERBAIK", "x" .. tostring(best_combo or 0), row_x, py + 284, row_w)

  -- Top five scores on the right side
  local top_x = px + 316
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.print("TOP 5", top_x, py + 84)
  for i = 1, 5 do
    local value = top_scores and top_scores[i] or 0
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
    love.graphics.print(i .. ".", top_x, py + 124 + (i - 1) * 40)
    love.graphics.setColor(
      i == 1 and theme.yellow[1] or theme.text[1],
      i == 1 and theme.yellow[2] or theme.text[2],
      i == 1 and theme.yellow[3] or theme.text[3],
      1
    )
    love.graphics.print(tostring(value), top_x + 36, py + 124 + (i - 1) * 40)
  end

  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("ESC atau TAB untuk kembali", px, py + panel_h + 12, panel_w, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

-- ---------------------------------------------------------- v2 screens

ui.screen = nil -- "modes" | "settings" | "codex" | "achievements" | "profiles" | "replay" | "shop"
ui.selection = 1
ui.showDraft = function(options)
  ui.draft = options
end
ui.hideDraft = function()
  ui.draft = nil
end
ui.draft = nil

local function overlay_panel(title, w, h)
  w = w or 620
  h = h or 460
  local px, py = 400 - w / 2, 300 - h / 2
  love.graphics.setColor(0.01, 0.012, 0.02, 0.9)
  love.graphics.rectangle("fill", 0, 0, 800, 600)
  draw_chip(px, py, w, h)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 0.8)
  love.graphics.setLineWidth(2)
  round_rect("line", px, py, w, h, 12)
  love.graphics.setLineWidth(1)
  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.printf(title, px, py + 16, w, "center")
  return px, py, w, h
end

local function menu_row(text, x, y, w, selected, hint)
  love.graphics.setColor(
    selected and theme.cyan[1] or theme.text_dim[1],
    selected and theme.cyan[2] or theme.text_dim[2],
    selected and theme.cyan[3] or theme.text_dim[3],
    1
  )
  love.graphics.setFont(FONTS.body)
  love.graphics.print(selected and ("> " .. text) or ("  " .. text), x, y)
  if hint then
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
    love.graphics.printf(hint, x + 200, y + 2, w - 220, "right")
  end
end

function ui.drawModeSelect(modes, selection)
  local px, py, w, h = overlay_panel("PILIH MODE", 640, 500)
  for i, mode in ipairs(modes.list) do
    menu_row(mode.name, px + 40, py + 84 + (i - 1) * 38, w - 80, i == selection, mode.hint)
  end
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("PANAH pilih   ·   ENTER mulai   ·   ESC kembali", px, py + h - 42, w, "center")
end

local SETTING_KEYS = { "music_volume", "sfx_volume", "shake", "flash", "colorblind", "reduced_motion" }
local SETTING_NAMES = { "VOLUME MUSIK", "VOLUME SFX", "GETAR", "KILAT", "BUTA WARNA", "GERAK MINIMAL" }

function ui.drawSettings(values, selection)
  local px, py, w, h = overlay_panel("PENGATURAN", 620, 440)
  for i, key in ipairs(SETTING_KEYS) do
    local value = values[key] or 0
    local text = SETTING_NAMES[i] .. "  " .. string.format("%.2f", value)
    menu_row(text, px + 40, py + 80 + (i - 1) * 42, w - 80, i == selection)
  end
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("PANAH ubah   ·   ESC simpan dan kembali", px, py + h - 40, w, "center")
end

function ui.setting_key(index)
  return SETTING_KEYS[index]
end

function ui.setting_count()
  return #SETTING_KEYS
end

function ui.drawCodex(entries, selection)
  local px, py, w, h = overlay_panel("KODEKS ATURAN", 660, 500)
  local first = math.max(1, selection - 5)
  for i = first, math.min(#entries, first + 9) do
    local e = entries[i]
    local text = string.format("%02d. %s", i, e.name)
    menu_row(text, px + 30, py + 72 + (i - first) * 34, w - 60, i == selection)
  end
  local e = entries[selection]
  if e then
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
    love.graphics.printf(e.hint .. "   [" .. e.tags .. "]", px + 30, py + h - 60, w - 60, "left")
  end
end

function ui.drawAchievements(profile, list)
  local px, py, w, h = overlay_panel("PENCAPAIAN", 660, 500)
  for i, a in ipairs(list) do
    local col = i <= 10 and 0 or 1
    local row = (i - 1) % 10 + 1
    local done = profile.achievements and profile.achievements[a.id]
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(
      done and theme.yellow[1] or theme.text_mute[1],
      done and theme.yellow[2] or theme.text_mute[2],
      done and theme.yellow[3] or theme.text_mute[3],
      1
    )
    love.graphics.print((done and "[x] " or "[ ] ") .. a.name, px + 30 + col * 310, py + 76 + (row - 1) * 38)
  end
end

function ui.drawProfiles(profiles, slot, profile)
  local px, py, w, h = overlay_panel("PROFIL", 620, 400)
  for i = 1, 3 do
    local p = profiles[i]
    local text = "SLOT " .. i .. "  Level " .. p.level .. "  Skor " .. p.best_score
    menu_row(text, px + 40, py + 90 + (i - 1) * 48, w - 80, i == slot)
  end
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.printf("Koin: " .. profile.coins .. "   XP: " .. profile.xp, px, py + h - 70, w, "center")
end

function ui.drawReplay(rec, count)
  local px, py, w, h = overlay_panel("REPLAY", 620, 400)
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], 1)
  love.graphics.printf("Seed: " .. (rec.seed or 0) .. "   Mode: " .. (rec.mode or "-"), px, py + 90, w, "center")
  love.graphics.printf(
    "Frame terekam: " .. #(rec.frames or {}) .. "   Hantu: " .. (rec.ghost and "aktif" or "mati"),
    px,
    py + 140,
    w,
    "center"
  )
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("ENTER mulai replay   ·   ESC kembali", px, py + h - 60, w, "center")
end

function ui.drawShop(items, coins, selection)
  local px, py, w, h = overlay_panel("TOKO", 640, 460)
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
  love.graphics.print("Koin: " .. coins, px + 40, py + 68)
  for i, item in ipairs(items) do
    menu_row(
      item.name .. "  (" .. item.cost .. ")",
      px + 40,
      py + 100 + (i - 1) * 42,
      w - 80,
      i == selection,
      item.hint
    )
  end
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("PANAH pilih   ·   ENTER beli   ·   ESC lanjut", px, py + h - 40, w, "center")
end

function ui.drawDraft(options)
  local px, py, w, h = overlay_panel("PILIH ATURAN", 640, 300)
  for i, rule in ipairs(options) do
    menu_row(i .. ". " .. rule.name, px + 40, py + 84 + (i - 1) * 44, w - 80, false, rule.hint)
  end
end

function ui.drawMenuHint(text)
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf(text, 40, 552, 720, "center")
end

function ui.drawCampaign(chapters, progress, selection)
  local px, py, w, h = overlay_panel("KAMPANYE", 660, 500)
  for i, ch in ipairs(chapters) do
    local status = i < progress and "[x]" or (i == progress and "[>]" or "[ ]")
    menu_row(status .. " " .. i .. ". " .. ch.name, px + 30, py + 72 + (i - 1) * 38, w - 60, i == selection, ch.hint)
  end
end

function ui.drawCosmetics(skins, level, selection)
  local px, py, w, h = overlay_panel("SKIN PLAYER", 640, 460)
  for i, skin in ipairs(skins) do
    local locked = skin.level > level
    menu_row(
      i .. ". " .. skin.name .. (locked and " [TERKUNCI]" or ""),
      px + 40,
      py + 72 + (i - 1) * 40,
      w - 80,
      i == selection
    )
  end
end

function ui.drawMultiplayerMenu(items, selection)
  local px, py, w, h = overlay_panel("MULTIPLAYER", 620, 330)
  for i, item in ipairs(items) do
    menu_row(item.name, px + 40, py + 84 + (i - 1) * 46, w - 80, i == selection, item.hint)
  end
end

function ui.drawCrafting(conditions, effects, cond_index, effect_index)
  local px, py, w, h = overlay_panel("BUAT ATURAN", 660, 420)
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.print("KONDISI", px + 30, py + 70)
  love.graphics.print("EFEK", px + 340, py + 70)
  for i, c in ipairs(conditions) do
    menu_row(c.name, px + 30, py + 100 + (i - 1) * 38, 280, i == cond_index)
  end
  for i, e in ipairs(effects) do
    menu_row(e.name, px + 340, py + 100 + (i - 1) * 38, 280, i == effect_index)
  end
end

function ui.drawLeaderboard(board)
  local px, py, w, h = overlay_panel("PAPAN SKOR HARIAN", 620, 420)
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.print(board.date or "-", px + 40, py + 70)
  for i = 1, 10 do
    local score = board.scores and board.scores[i] or 0
    love.graphics.print(i .. ".  " .. score, px + 40, py + 106 + (i - 1) * 30)
  end
end

function ui.drawTournament(t)
  local px, py, w, h = overlay_panel("TURNAMENT", 620, 420)
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.print("Babak " .. t.round .. "  Pertandingan " .. t.match, px + 40, py + 70)
  for i, name in ipairs(t.results or {}) do
    love.graphics.print(i .. ". " .. name, px + 40, py + 110 + (i - 1) * 32)
  end
end

function ui.drawRecap(r, font)
  r.draw(r, font or FONTS.body)
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("ESC kembali ke menu", 200, 440, 400, "center")
end

function ui.drawThemeEditor(state, accents, presets, selection)
  local px, py, w, h = overlay_panel("TEMA", 640, 440)
  for i, accent in ipairs(accents) do
    local c = accent.color
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.rectangle("fill", px + 40, py + 70 + (i - 1) * 36, 20, 20, 4, 4)
    menu_row(accent.name, px + 70, py + 70 + (i - 1) * 36, 260, i == state.accent)
  end
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  menu_row("PRESET: " .. presets[state.preset], px + 340, py + 70, 260, true)
  love.graphics.setFont(FONTS.small)
  love.graphics.printf("PANAH pilih   ·   ENTER simpan   ·   ESC kembali", px, py + h - 40, w, "center")
end

function ui.drawModManager(items, selection, conflict)
  local px, py, w, h = overlay_panel("MOD MANAGER", 660, 460)
  for i, item in ipairs(items) do
    menu_row(
      (item.enabled and "[x] " or "[ ] ") .. item.name,
      px + 40,
      py + 76 + (i - 1) * 36,
      w - 80,
      i == selection,
      item.source
    )
  end
  if conflict then
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(1, 0.3, 0.36, 1)
    love.graphics.printf("KONFLIK TAG: " .. conflict, px, py + h - 60, w, "center")
  end
end

function ui.drawOnboarding(step)
  local px, py, w, h = overlay_panel("PANDUAN CEPAT", 620, 360)
  local messages = {
    { "GERAK", "A / D atau panah untuk menggeser kotak." },
    { "TANGKAP", "Makanan hijau menambah skor. Musuh merah mengurangi nyawa." },
    { "ATURAN", "Aturan berganti tiap 30 detik. Perhatikan banner." },
  }
  local m = messages[step] or messages[1]
  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.printf(m[1], px, py + 90, w, "center")
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.printf(m[2], px + 30, py + 160, w - 60, "center")
  love.graphics.setFont(FONTS.small)
  love.graphics.printf("ENTER lanjut   ·   ESC lewati", px, py + h - 50, w, "center")
end

ui.FONTS = FONTS

return ui
