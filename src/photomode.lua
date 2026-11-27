-- src/photomode.lua
-- Freeze the game, draw an overlay and export a PNG to the save directory.

local photomode = {}

photomode.active = false
photomode.show_stats = true
photomode.watermark = true

function photomode.toggle()
  photomode.active = not photomode.active
end

function photomode.draw(font)
  if not photomode.active then
    return
  end
  love.graphics.setColor(0.01, 0.012, 0.02, 0.35)
  love.graphics.rectangle("fill", 0, 0, 800, 600)
  love.graphics.setFont(font or love.graphics.newFont(20))
  love.graphics.setColor(0.122, 0.780, 0.937, 1)
  love.graphics.printf("FOTO MODE", 0, 40, 800, "center")
  if photomode.watermark then
    love.graphics.setColor(0.62, 0.66, 0.75, 0.6)
    love.graphics.printf("FLIP30  v4.0", 0, 566, 800, "center")
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function photomode.capture(game_state)
  if not love or not love.graphics or not love.graphics.captureScreenshot then
    return false
  end
  local name = "flip30_photo_" .. tostring(os.time()) .. ".png"
  love.graphics.captureScreenshot(function(imagedata)
    local ok, png = pcall(imagedata.encode, imagedata, "png")
    if ok and png then
      local file = io.open(name, "wb")
      if file then
        file:write(png:getString())
        file:close()
        print("[photomode] wrote " .. name)
      end
    end
  end)
  return true
end

return photomode
