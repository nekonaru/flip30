-- src/toast.lua
-- Transient notification stack for achievements, records and hints.

local toast = {}

toast.items = {}

function toast.push(text, color, duration)
  table.insert(toast.items, {
    text = text,
    color = color or { 0.122, 0.780, 0.937 },
    t = 0,
    duration = duration or 2.4,
  })
end

function toast.update(dt)
  for i = #toast.items, 1, -1 do
    toast.items[i].t = toast.items[i].t + dt
    if toast.items[i].t >= toast.items[i].duration then
      table.remove(toast.items, i)
    end
  end
end

function toast.draw(font)
  local y = 60
  for i, item in ipairs(toast.items) do
    local p = item.t / item.duration
    local alpha = p < 0.1 and p / 0.1 or (p > 0.8 and (1 - p) / 0.2 or 1)
    local c = item.color
    love.graphics.setColor(0.02, 0.03, 0.05, 0.85 * alpha)
    love.graphics.rectangle("fill", 220, y - 6, 360, 34, 8, 8)
    love.graphics.setColor(c[1], c[2], c[3], alpha)
    love.graphics.rectangle("line", 220, y - 6, 360, 34, 8, 8)
    love.graphics.setFont(font or love.graphics.newFont(16))
    love.graphics.printf(item.text, 220, y + 2, 360, "center")
    y = y + 42
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function toast.clear()
  toast.items = {}
end

return toast
