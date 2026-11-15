-- LAYAR GELAP: only a small circle of light around the player is visible.
local gradient = nil

local function get_gradient()
  if gradient then
    return gradient
  end
  local size = 220
  local data = love.image.newImageData(size, size)
  for y = 0, size - 1 do
    for x = 0, size - 1 do
      local dx = (x - size / 2) / (size / 2)
      local dy = (y - size / 2) / (size / 2)
      local dist = math.sqrt(dx * dx + dy * dy)
      -- smoothstep(0.14, 0.60, dist) * 0.94
      local t = math.max(0, math.min(1, (dist - 0.14) / (0.60 - 0.14)))
      local alpha = t * t * (3 - 2 * t) * 0.94
      data:setPixel(x, y, 0.008, 0.010, 0.016, alpha)
    end
  end
  gradient = love.graphics.newImage(data)
  return gradient
end

return {
  name = "LAYAR GELAP",
  tags = { "vision" },
  hint = "Hanya cahaya di sekitar kamu",
  apply = function(ctx)
    ctx.world.darkness = 1
  end,
  revert = function(ctx)
    ctx.world.darkness = 0
  end,
  draw = function(ctx)
    if ctx.world.darkness <= 0 then
      return
    end
    local p = ctx.player
    local cx = p.x + p.w / 2
    local cy = p.y + p.h / 2
    local img = get_gradient()
    local scale = 1700 / img:getWidth()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(img, cx - 850, cy - 850, 0, scale, scale)
    love.graphics.setColor(1, 1, 1, 1)
  end,
}
