-- src/replay.lua
-- Records one input frame per fixed simulation step and replays them as a ghost.

local replay = {}

local STEP = 1 / 60

function replay.new()
  return { frames = {}, seed = 0, mode = "classic", playing = false, index = 1, ghost = nil }
end

function replay.begin(rec, seed, mode)
  rec.frames = {}
  rec.seed = seed
  rec.mode = mode
  rec.playing = true
  rec.index = 1
end

function replay.record(rec, input)
  if rec.playing and #rec.frames < 60 * 600 then
    table.insert(rec.frames, input)
  end
end

function replay.stop(rec)
  rec.playing = false
end

function replay.start_playback(rec)
  rec.playing = false
  rec.index = 1
  rec.ghost = { x = 380, y = 536, visible = true }
end

function replay.next(rec)
  local frame = rec.frames[rec.index]
  rec.index = rec.index + 1
  return frame
end

function replay.has_frame(rec)
  return rec.frames and rec.frames[rec.index] ~= nil
end

replay.STEP = STEP

return replay
