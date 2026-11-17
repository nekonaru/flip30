-- src/storage.lua
-- High score persistence via love.filesystem (stored as `highscore.txt`).
-- `storage.parse` is pure so it can be unit-tested without LÖVE.

local storage = {}

local FILE_NAME = "highscore.txt"
local BEST_COMBO_FILE = "bestcombo.txt"
local GAMES_FILE = "games.txt"
local STATS_FILE = "stats.txt" -- "total_time total_score total_food"

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

function storage.loadStats()
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return { time = 0, score = 0, food = 0 }
  end
  local ok, exists = pcall(love.filesystem.getInfo, STATS_FILE)
  if not ok or not exists then
    return { time = 0, score = 0, food = 0 }
  end
  local ok_read, data = pcall(love.filesystem.read, STATS_FILE)
  if not ok_read then
    return { time = 0, score = 0, food = 0 }
  end
  return storage.parseStats(data)
end

function storage.saveStats(stats)
  if not (love and love.filesystem) then
    return false
  end
  local ok, written = pcall(
    love.filesystem.write,
    STATS_FILE,
    string.format("%d %d %d", math.floor(stats.time or 0), math.floor(stats.score or 0), math.floor(stats.food or 0))
  )
  return ok and written and true or false
end

-- Pure parser, used by both the loader and the headless tests
function storage.parseStats(raw)
  if type(raw) ~= "string" then
    return { time = 0, score = 0, food = 0 }
  end
  local a, b, c = raw:match("(%d+)%s+(%d+)%s+(%d+)")
  return {
    time = tonumber(a) or 0,
    score = tonumber(b) or 0,
    food = tonumber(c) or 0,
  }
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
