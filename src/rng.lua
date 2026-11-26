-- src/rng.lua
-- Shared deterministic random source. Every gameplay roll uses this generator
-- so a seed plus recorded inputs can reproduce a run exactly.

local rng = {}

local seed = 12345
local function next_random()
  seed = (seed * 1103515245 + 12345) % 2147483648
  return seed / 2147483648
end

function rng.set_seed(value)
  seed = math.floor(tonumber(value) or 12345) % 2147483648
  if seed <= 0 then
    seed = 12345
  end
end

function rng.get_seed()
  return seed
end

-- Mirrors the Lua math.random API surface used by gameplay modules
function rng.random(a, b)
  if a == nil then
    return next_random()
  elseif b == nil then
    return math.floor(next_random() * a) + 1
  end
  return math.floor(next_random() * (b - a + 1)) + a
end

return rng
