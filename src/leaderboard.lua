-- src/leaderboard.lua
-- Local daily leaderboard, ten entries per date.

local leaderboard = {}

local FILE = "dailyboard.txt"

function leaderboard.new()
  return { date = "", scores = {} }
end

local function parse(raw)
  local board = leaderboard.new()
  if type(raw) ~= "string" then
    return board
  end
  local line_count = 0
  for line in raw:gmatch("[^\r\n]+") do
    if line_count == 0 then
      board.date = line
    else
      local score = tonumber(line)
      if score then
        table.insert(board.scores, score)
      end
    end
    line_count = line_count + 1
  end
  return board
end

local function serialize(board)
  local lines = { board.date or "" }
  for _, score in ipairs(board.scores or {}) do
    table.insert(lines, tostring(math.floor(score)))
  end
  return table.concat(lines, "\n")
end

function leaderboard.load()
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return leaderboard.new()
  end
  local ok, exists = pcall(love.filesystem.getInfo, FILE)
  if not ok or not exists then
    return leaderboard.new()
  end
  local ok_read, data = pcall(love.filesystem.read, FILE)
  if not ok_read then
    return leaderboard.new()
  end
  return parse(data)
end

function leaderboard.submit(board, date, score)
  if board.date ~= date then
    board.date = date
    board.scores = {}
  end
  table.insert(board.scores, score)
  table.sort(board.scores, function(a, b)
    return a > b
  end)
  while #board.scores > 10 do
    table.remove(board.scores)
  end
  if love and love.filesystem then
    pcall(love.filesystem.write, FILE, serialize(board))
  end
  return board
end

leaderboard.parse = parse
leaderboard.serialize = serialize

return leaderboard
