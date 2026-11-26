-- src/progression.lua
-- XP, levels, coins, unlockables and three local profiles.

local progression = {}

local FILE = "profile%d.txt"

local DEFAULTS = {
  xp = 0,
  level = 1,
  coins = 0,
  total_runs = 0,
  best_score = 0,
  unlocked_skins = 1,
  unlocked_rules = 8,
}

function progression.new()
  local t = {}
  for k, v in pairs(DEFAULTS) do
    t[k] = v
  end
  t.achievements = {}
  return t
end

local function parse(raw)
  local t = progression.new()
  if type(raw) ~= "string" then
    return t
  end
  for line in raw:gmatch("[^\r\n]+") do
    local key, value = line:match("^%s*([%w_]+)%s*=%s*([%d%.%-]+)%s*$")
    if key and DEFAULTS[key] ~= nil then
      local n = tonumber(value)
      if n then
        t[key] = n
      end
    end
  end
  return t
end

local function serialize(t)
  local lines = {}
  for key, value in pairs(t) do
    if DEFAULTS[key] ~= nil then
      table.insert(lines, key .. "=" .. tostring(math.floor(value)))
    end
  end
  for id in pairs(t.achievements or {}) do
    table.insert(lines, "a_" .. id .. "=1")
  end
  table.sort(lines)
  return table.concat(lines, "\n")
end

function progression.load(slot)
  slot = math.max(1, math.min(3, slot or 1))
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return progression.new()
  end
  local path = string.format(FILE, slot)
  local ok, exists = pcall(love.filesystem.getInfo, path)
  if not ok or not exists then
    return progression.new()
  end
  local ok_read, data = pcall(love.filesystem.read, path)
  if not ok_read then
    return progression.new()
  end
  local t = parse(data)
  for line in (data or ""):gmatch("[^\r\n]+") do
    local id = line:match("^a_([%w_]+)=1$")
    if id then
      t.achievements[id] = true
    end
  end
  return t
end

function progression.save(slot, t)
  if not (love and love.filesystem) then
    return false
  end
  local ok, written = pcall(love.filesystem.write, string.format(FILE, slot), serialize(t))
  return ok and written and true or false
end

function progression.xp_for_level(level)
  return 100 + (level - 1) * 50
end

function progression.add_xp(t, amount)
  t.xp = t.xp + amount
  while t.xp >= progression.xp_for_level(t.level) do
    t.xp = t.xp - progression.xp_for_level(t.level)
    t.level = t.level + 1
    t.unlocked_skins = math.min(8, t.unlocked_skins + 1)
    t.unlocked_rules = math.min(30, t.unlocked_rules + 1)
  end
end

progression.parse = parse
progression.serialize = serialize

return progression
