-- src/settings.lua
-- Persisted player settings: volumes shake, flash and color mode.
-- Stored as simple key=value lines in the save directory.

local settings = {}

local FILE = "settings.txt"

local DEFAULTS = {
  music_volume = 0.18,
  sfx_volume = 1.0,
  shake = 1.0,
  flash = 1.0,
  colorblind = 0,
  reduced_motion = 0,
}

local function default()
  local t = {}
  for k, v in pairs(DEFAULTS) do
    t[k] = v
  end
  return t
end

local function parse(raw)
  local t = default()
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

function settings.load()
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return default()
  end
  local ok, exists = pcall(love.filesystem.getInfo, FILE)
  if not ok or not exists then
    return default()
  end
  local ok_read, data = pcall(love.filesystem.read, FILE)
  if not ok_read then
    return default()
  end
  return parse(data)
end

function settings.save(t)
  if not (love and love.filesystem) then
    return false
  end
  local lines = {}
  for key, value in pairs(t) do
    if DEFAULTS[key] ~= nil then
      table.insert(lines, key .. "=" .. tostring(value))
    end
  end
  table.sort(lines)
  local ok, written = pcall(love.filesystem.write, FILE, table.concat(lines, "\n"))
  return ok and written and true or false
end

settings.parse = parse
settings.default = default

return settings
