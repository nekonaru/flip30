-- src/multiplayer.lua
-- Local multiplayer: co-op shared arena and versus split arena.

local multiplayer = {}

multiplayer.modes = {
  { id = "coop", name = "CO-OP", hint = "Bermain bareng, satu arena" },
  { id = "versus", name = "VERSUS", hint = "Arena terbagi, skor tertinggi menang" },
  { id = "hotseat", name = "HOT-SEAT", hint = "Bergiliran tiap 30 detik" },
}

function multiplayer.new()
  return {
    enabled = false,
    mode = "coop",
    p1 = { x = 0, y = 536, w = 40, h = 40, score = 0, lives = 3 },
    p2 = { x = 200, y = 536, w = 40, h = 40, score = 0, lives = 3 },
    turn = 1,
  }
end

function multiplayer.begin(mp, mode)
  mp.enabled = true
  mp.mode = mode or "coop"
  mp.p1.score, mp.p2.score = 0, 0
  mp.p1.lives, mp.p2.lives = 3, 3
  mp.turn = 1
end

function multiplayer.keys(player_index)
  if player_index == 1 then
    return { left = "a", right = "d", dash = "lshift" }
  end
  return { left = "left", right = "right", dash = "rshift" }
end

function multiplayer.winner(mp)
  if mp.p1.score > mp.p2.score then
    return 1
  end
  if mp.p2.score > mp.p1.score then
    return 2
  end
  return 0
end

return multiplayer
