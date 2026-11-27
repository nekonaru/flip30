-- src/tournament.lua
-- Eight-player hot-seat tournament bracket.

local tournament = {}

function tournament.new()
  return { players = {}, round = 1, match = 1, results = {} }
end

function tournament.begin(t, names)
  t.players = {}
  for i = 1, 8 do
    t.players[i] = { name = names[i] or ("P" .. i), score = 0 }
  end
  t.round, t.match, t.results = 1, 1, {}
end

function tournament.pair(t)
  local a = t.players[t.match]
  local b = t.players[9 - t.match]
  return a, b
end

function tournament.record(t, winner_index)
  local a, b = tournament.pair(t)
  local winner = winner_index == 1 and a or b
  table.insert(t.results, winner.name)
  t.match = t.match + 1
  if t.match > 4 then
    t.round = t.round + 1
    t.match = 1
  end
end

function tournament.done(t)
  return #t.results >= 7
end

return tournament
