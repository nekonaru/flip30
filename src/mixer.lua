-- src/mixer.lua
-- Three-band procedural audio mixer. Store gains in settings file.

local mixer = {}

mixer.bands = {
  { id = "bass", name = "BASS", key = "bass_gain", default = 1 },
  { id = "mid", name = "MID", key = "mid_gain", default = 1 },
  { id = "high", name = "HIGH", key = "high_gain", default = 1 },
}

function mixer.ensure(settings)
  for _, b in ipairs(mixer.bands) do
    if settings[b.key] == nil then
      settings[b.key] = b.default
    end
  end
  return settings
end

function mixer.adjust(settings, index, delta)
  local b = mixer.bands[index]
  if not b then
    return
  end
  mixer.ensure(settings)
  settings[b.key] = math.max(0, math.min(2, (settings[b.key] or 1) + delta))
end

function mixer.music_volume(settings)
  mixer.ensure(settings)
  local base = settings.music_volume or 0.18
  return base * ((settings.bass_gain or 1) + (settings.mid_gain or 1) + (settings.high_gain or 1)) / 3
end

return mixer
