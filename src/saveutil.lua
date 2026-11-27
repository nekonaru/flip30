-- src/saveutil.lua
-- Backup, migration and repair for the flat text save files.

local saveutil = {}

local FILES = {
  "highscore.txt",
  "bestcombo.txt",
  "games.txt",
  "stats.txt",
  "scores.txt",
  "settings.txt",
  "profile1.txt",
  "profile2.txt",
  "profile3.txt",
  "dailyboard.txt",
  "profile_export.txt",
}

function saveutil.list_files()
  local out = {}
  for _, f in ipairs(FILES) do
    table.insert(out, f)
  end
  return out
end

function saveutil.backup()
  if not (love and love.filesystem) then
    return false
  end
  local lines = {}
  for _, file in ipairs(FILES) do
    local ok, exists = pcall(love.filesystem.getInfo, file)
    if ok and exists then
      local ok_read, data = pcall(love.filesystem.read, file)
      if ok_read and data then
        table.insert(lines, "FILE:" .. file)
        table.insert(lines, data)
        table.insert(lines, "ENDFILE")
      end
    end
  end
  local ok, written = pcall(love.filesystem.write, "backup_all.txt", table.concat(lines, "\n"))
  return ok and written and true or false
end

function saveutil.restore()
  if not (love and love.filesystem) then
    return false
  end
  local ok, exists = pcall(love.filesystem.getInfo, "backup_all.txt")
  if not ok or not exists then
    return false
  end
  local ok_read, data = pcall(love.filesystem.read, "backup_all.txt")
  if not ok_read or not data then
    return false
  end
  local current = nil
  local buffer = {}
  for line in data:gmatch("[^\r\n]*") do
    if line:match("^FILE:") then
      current = line:sub(6)
      buffer = {}
    elseif line == "ENDFILE" then
      if current then
        pcall(love.filesystem.write, current, table.concat(buffer, "\n"))
      end
      current = nil
    elseif current then
      table.insert(buffer, line)
    end
  end
  return true
end

function saveutil.verify()
  if not (love and love.filesystem and love.filesystem.getInfo) then
    return false
  end
  local problems = {}
  for _, file in ipairs(FILES) do
    local ok, exists = pcall(love.filesystem.getInfo, file)
    if ok and exists then
      local ok_read, data = pcall(love.filesystem.read, file)
      if not ok_read or not data then
        table.insert(problems, file)
      end
    end
  end
  return #problems == 0, problems
end

return saveutil
