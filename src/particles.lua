-- src/particles.lua
-- Tiny sparkle bursts, driven by one shared ParticleSystem with a
-- procedurally generated soft-dot sprite (no external assets).

local particles = {}

local system = nil

function particles.load()
  local size = 16
  local data = love.image.newImageData(size, size)
  for y = 0, size - 1 do
    for x = 0, size - 1 do
      local dx = x - (size - 1) / 2
      local dy = y - (size - 1) / 2
      local dist = math.sqrt(dx * dx + dy * dy) / ((size - 1) / 2)
      local alpha = math.max(0, 1 - dist)
      data:setPixel(x, y, 1, 1, 1, alpha * alpha)
    end
  end
  local image = love.graphics.newImage(data)

  system = love.graphics.newParticleSystem(image, 256)
  system:setParticleLifetime(0.35, 0.85)
  system:setSpeed(50, 190)
  system:setSpread(math.pi * 2)
  system:setLinearAcceleration(0, 140, 0, 320)
  system:setSizes(0.9, 0.4)
  system:setSizeVariation(0.6)
  system:setColors(1, 1, 1, 1, 1, 1, 1, 0)
  system:setEmissionRate(0)
end

function particles.burst(x, y, r, g, b, count)
  if not system then return end
  system:setPosition(x, y)
  system:setColors(r, g, b, 1, r, g, b, 0)
  system:emit(count or 14)
end

function particles.update(dt)
  if system then
    system:update(dt)
  end
end

function particles.draw()
  if system then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(system)
  end
end

return particles
