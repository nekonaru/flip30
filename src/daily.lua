-- src/daily.lua
-- Daily seed derived from the calendar date for reproducible daily runs.

local daily = {}

function daily.seed()
  local d = os.date("*t")
  return d.year * 10000 + d.month * 100 + d.day
end

function daily.label()
  return os.date("%d/%m/%Y")
end

return daily
