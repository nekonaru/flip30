-- src/storage.lua
-- High score persistence via love.filesystem (stored as `highscore.txt`).
-- `storage.parse` is pure so it can be unit-tested without LÖVE.

local storage = {}

local FILE_NAME = "highscore.txt"
local BEST_COMBO_FILE = "bestcombo.txt"
local GAMES_FILE = "games.txt"

-- Parses a raw file body into a non-negative integer score.
-- Corrupt or missing data yields 0.
function storage.parse(raw)
  if type(raw) ~= "string" then
    return 0
  end
  local n = tonumber(raw:match("^%s*(-?%d+)"))
  if not n or n < 0 then
    return 0
  end
  return math.floor(n)
end

function storage.load()
  if not (love and love.filesystem) then
    return 0
  end
  local ok, exists = pcall(love.filesystem.getInfo, FILE_NAME)
  if not ok or not exists then
    return 0
  end
  local ok_read, data = pcall(love.filesystem.read, FILE_NAME)
  if not ok_read then
    return 0
  end
  return storage.parse(data)
end

function storage.save(score)
  if not (love and love.filesystem) then
    return false
  end
  local ok, written = pcall(love.filesystem.write, FILE_NAME, tostring(math.floor(score)))
  return ok and written and true or false
end

function storage.loadBestCombo()
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return 0
  end
  local ok, exists = pcall(love.filesystem.getInfo, BEST_COMBO_FILE)
  if not ok or not exists then
    return 0
  end
  local ok_read, data = pcall(love.filesystem.read, BEST_COMBO_FILE)
  if not ok_read then
    return 0
  end
  return storage.parse(data)
end

function storage.saveBestCombo(combo)
  if not (love and love.filesystem) then
    return false
  end
  local ok, written = pcall(love.filesystem.write, BEST_COMBO_FILE, tostring(math.floor(combo)))
  return ok and written and true or false
end

function storage.loadGamesCount()
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return 0
  end
  local ok, exists = pcall(love.filesystem.getInfo, GAMES_FILE)
  if not ok or not exists then
    return 0
  end
  local ok_read, data = pcall(love.filesystem.read, GAMES_FILE)
  if not ok_read then
    return 0
  end
  return storage.parse(data)
end

function storage.saveGamesCount(count)
  if not (love and love.filesystem) then
    return false
  end
  local ok, written = pcall(love.filesystem.write, GAMES_FILE, tostring(math.floor(count)))
  return ok and written and true or false
end

return storage
