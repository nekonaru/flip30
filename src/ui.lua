-- src/ui.lua
-- Immediate-mode style UI helpers: menu, HUD, banner, popups, game over.

local ui = {}

ui.banner = nil -- { text = string, t = number, duration = number }
ui.popups = {}  -- { x, y, text, color, t }

local FONTS = {}
local LOGO = nil
local ICON = nil

function ui.load()
  FONTS.small = love.graphics.newFont(14)
  FONTS.body = love.graphics.newFont(20)
  FONTS.big = love.graphics.newFont(44)
  FONTS.huge = love.graphics.newFont(72)

  local ok_logo, logo = pcall(love.graphics.newImage, "assets/brand/logo-main.png")
  if ok_logo then LOGO = logo end
  local ok_icon, icon = pcall(love.graphics.newImage, "assets/brand/icon-512.png")
  if ok_icon then ICON = icon end
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
  if not ui.banner then return end
  local b = ui.banner
  local p = math.min(1, b.t / b.duration)
  local in_p = math.min(1, p / 0.22)
  local scale = ease_out_back(in_p)
  local alpha = p > 0.72 and math.max(0, 1 - (p - 0.72) / 0.28) or 1

  love.graphics.push()
  love.graphics.translate(400, 210)
  love.graphics.scale(scale, scale)

  -- Contrast bar behind the text
  love.graphics.setColor(0.03, 0.04, 0.07, 0.78 * alpha)
  love.graphics.rectangle("fill", -330, -58, 660, 116, 14, 14)
  love.graphics.setColor(0.12, 0.78, 0.94, 0.9 * alpha)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", -330, -58, 660, 116, 14, 14)
  love.graphics.setLineWidth(1)

  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(0, 0, 0, alpha)
  love.graphics.printf(b.text .. "!", -326, -24 + 3, 660, "center")
  love.graphics.setColor(1.000, 0.824, 0.247, alpha)
  love.graphics.printf(b.text .. "!", -330, -24, 660, "center")
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
end

-- ------------------------------------------------------------- widgets

local heart_points = nil
local function heartPolygon()
  if heart_points then return heart_points end
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

-- --------------------------------------------------------------- menu

function ui.drawMenu(highscore, time)
  love.graphics.setColor(1, 1, 1, 1)

  local pulse = 0.5 + 0.5 * math.sin((time or 0) * 1.8)

  if LOGO then
    local lw = 560
    local scale = lw / LOGO:getWidth()
    local lh = LOGO:getHeight() * scale
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(LOGO, 400 - lw / 2, 96, 0, scale, scale)
  elseif ICON then
    local s = 220 / ICON:getWidth()
    love.graphics.draw(ICON, 400 - 110, 90, 0, s, s)
  end

  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(0.62, 0.66, 0.75, 1)
  love.graphics.printf("Tangkap makanan, hindari musuh. Aturan berubah tiap 30 detik.", 60, 330, 680, "center")

  love.graphics.setFont(FONTS.big)
  local glow = 0.75 + 0.25 * pulse
  love.graphics.setColor(0.12 * glow, 0.78 * glow, 0.94 * glow, 1)
  love.graphics.printf("TEKAN  ENTER", 60, 392, 680, "center")

  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(0.48, 0.52, 0.62, 1)
  love.graphics.printf("A / D  atau  PANAH untuk bergerak      ESC untuk keluar", 60, 460, 680, "center")

  if highscore > 0 then
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(1.000, 0.824, 0.247, 1)
    love.graphics.printf("SKOR TERBAIK:  " .. highscore, 60, 500, 680, "center")
  end
end

-- ---------------------------------------------------------------- HUD

function ui.drawHUD(score, lives, rule_name, timer, duration)
  -- Score
  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(0.62, 0.66, 0.75, 1)
  love.graphics.print("SKOR", 16, 12)
  love.graphics.setFont(FONTS.big)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print(tostring(score), 16, 30)

  -- Lives
  for i = 1, 3 do
    if i <= lives then
      ui.drawHeart(30 + (i - 1) * 34, 108, 1.0, 1.000, 0.243, 0.541, 1)
    else
      ui.drawHeart(30 + (i - 1) * 34, 108, 1.0, 0.30, 0.30, 0.36, 0.9)
    end
  end

  -- Active rule
  love.graphics.setFont(FONTS.small)
  love.graphics.setColor(0.12, 0.78, 0.94, 1)
  love.graphics.printf("ATURAN: " .. (rule_name or "NORMAL"), 200, 14, 400, "center")

  -- Rule countdown bar (thin, top of screen)
  local fraction = duration and duration > 0 and math.max(0, math.min(1, timer / duration)) or 1
  love.graphics.setColor(0.07, 0.08, 0.12, 1)
  love.graphics.rectangle("fill", 0, 0, 800, 5)
  love.graphics.setColor(0.12, 0.78, 0.94, 0.95)
  love.graphics.rectangle("fill", 0, 0, 800 * fraction, 5)

  love.graphics.setColor(1, 1, 1, 1)
end

-- ---------------------------------------------------------- game over

function ui.drawGameOver(score, highscore, new_record, time)
  love.graphics.setColor(0.02, 0.02, 0.05, 0.72)
  love.graphics.rectangle("fill", 0, 0, 800, 600)

  -- Panel
  love.graphics.setColor(0.06, 0.07, 0.11, 0.96)
  love.graphics.rectangle("fill", 190, 120, 420, 340, 16, 16)
  love.graphics.setColor(0.12, 0.78, 0.94, 0.85)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", 190, 120, 420, 340, 16, 16)
  love.graphics.setLineWidth(1)

  love.graphics.setFont(FONTS.huge)
  love.graphics.setColor(1.000, 0.243, 0.541, 1)
  love.graphics.printf("GAME OVER", 190, 150, 420, "center")

  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(0.62, 0.66, 0.75, 1)
  love.graphics.printf("SKOR AKHIR", 190, 248, 420, "center")

  love.graphics.setFont(FONTS.huge)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(tostring(score), 190, 272, 420, "center")

  if new_record then
    local pulse = 0.7 + 0.3 * math.sin((time or 0) * 6)
    love.graphics.setFont(FONTS.big)
    love.graphics.setColor(1.000, 0.824, 0.247, pulse)
    love.graphics.printf("REKOR BARU!", 190, 348, 420, "center")
    love.graphics.setFont(FONTS.small)
    love.graphics.setColor(0.62, 0.66, 0.75, 1)
    love.graphics.printf("Skor terbaik: " .. highscore, 190, 404, 420, "center")
  else
    love.graphics.setFont(FONTS.body)
    love.graphics.setColor(1.000, 0.824, 0.247, 1)
    love.graphics.printf("TERBAIK: " .. highscore, 190, 366, 420, "center")
  end

  love.graphics.setFont(FONTS.body)
  love.graphics.setColor(0.85, 0.87, 0.92, 1)
  love.graphics.printf("ENTER: MAIN LAGI      ESC: MENU", 190, 430, 420, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

return ui
