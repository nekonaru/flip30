-- src/ui.lua
-- Immediate-mode style UI helpers: menu, HUD, banner, popups, pause and game over.

local theme = require("src.theme")

local ui = {}

ui.banner = nil -- { text = string, t = number, duration = number }
ui.popups = {} -- { x, y, text, color, t }
ui.version = nil

local FONTS = {}
local LOGO = nil
local ICON = nil
local BG_GRADIENT = nil

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

function ui.drawArenaBackground()
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

-- ---------------------------------------------------------------- banner

function ui.showBanner(text)
  ui.banner = { text = text, t = 0, duration = 2.0 }
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
  love.graphics.printf(b.text .. "!", -344, -21 + 3, 696, "center")
  love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], alpha)
  love.graphics.printf(b.text .. "!", -348, -21, 696, "center")
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

function ui.drawMenu(highscore, time)
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
    "A / D atau PANAH untuk bergerak   ·   P untuk pause   ·   ESC untuk keluar",
    40,
    452,
    720,
    "center"
  )

  -- High score chip
  if highscore > 0 then
    local text = "SKOR TERBAIK   " .. tostring(highscore)
    local font_w = FONTS.body:getWidth(text) + 44
    local chip_x = 400 - font_w / 2
    draw_chip(chip_x, 488, font_w, 34)
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
    love.graphics.printf(text, chip_x, 494, font_w, "center")
  end

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

function ui.drawHUD(score, lives, rule_name, timer, duration, elapsed, double_rules)
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

  -- Rule pill, top-center
  local rule_text = rule_name or "NORMAL"
  love.graphics.setFont(FONTS.small)
  local pill_w = math.max(150, FONTS.small:getWidth(rule_text) + 78)
  draw_chip(400 - pill_w / 2, 12, pill_w, 30)
  love.graphics.setColor(theme.cyan[1], theme.cyan[2], theme.cyan[3], 1)
  love.graphics.printf(rule_text, 400 - pill_w / 2, 18, pill_w, "center")

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
  love.graphics.printf("P: lanjut bermain", px, py + 108, panel_w, "center")
  love.graphics.printf("ESC: kembali ke menu", px, py + 138, panel_w, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

-- ---------------------------------------------------------- game over

function ui.drawGameOver(score, highscore, new_record, time, survived)
  love.graphics.setColor(0.01, 0.012, 0.02, 0.74)
  love.graphics.rectangle("fill", 0, 0, 800, 600)

  local panel_w, panel_h = 430, 380
  local px, py = 185, 105
  draw_chip(px, py, panel_w, panel_h)
  love.graphics.setColor(theme.pink[1], theme.pink[2], theme.pink[3], 0.8)
  love.graphics.setLineWidth(2.5)
  round_rect("line", px, py, panel_w, panel_h, 10)
  love.graphics.setLineWidth(1)

  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.pink[1], theme.pink[2], theme.pink[3], 1)
  love.graphics.printf("GAME OVER", px, py + 24, panel_w, "center")

  -- Two stat rows: score and survival time
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(theme.text_mute[1], theme.text_mute[2], theme.text_mute[3], 1)
  love.graphics.printf("SKOR AKHIR", px, py + 88, panel_w / 2, "center")
  love.graphics.printf("BERTAHAN", px + panel_w / 2, py + 88, panel_w / 2, "center")

  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(theme.text[1], theme.text[2], theme.text[3], 1)
  love.graphics.printf(tostring(score), px, py + 106, panel_w / 2, "center")
  love.graphics.printf(mmss(survived or 0), px + panel_w / 2, py + 106, panel_w / 2, "center")

  if new_record then
    local pulse = 0.7 + 0.3 * math.sin((time or 0) * 6)
    love.graphics.setFont(FONTS.big)
    love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], pulse)
    love.graphics.printf("REKOR BARU!", px, py + 178, panel_w, "center")
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
    love.graphics.printf("Skor terbaik: " .. highscore, px, py + 236, panel_w, "center")
  else
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(theme.yellow[1], theme.yellow[2], theme.yellow[3], 1)
    love.graphics.printf("TERBAIK: " .. highscore, px, py + 192, panel_w, "center")
  end

  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], 1)
  love.graphics.printf("ENTER: main lagi      ESC: menu", px, py + 292, panel_w, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

return ui
