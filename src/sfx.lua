-- src/sfx.lua
-- Procedural sound effects synthesized at load time. No audio files needed;
-- everything is generated as SoundData sine/square/triangle blips.

local sfx = {}

local sample_rate = 22050
local sources = {}
sfx.muted = false

local function make_tone(freq_from, freq_to, duration, wave, volume)
  local samples = math.floor(sample_rate * duration)
  local data = love.sound.newSoundData(samples, sample_rate, 16, 1)
  for i = 0, samples - 1 do
    local t = i / sample_rate
    local p = i / samples
    local freq = freq_from + (freq_to - freq_from) * p
    local raw
    if wave == "square" then
      raw = math.sin(2 * math.pi * freq * t) >= 0 and 1 or -1
    elseif wave == "triangle" then
      raw = 2 * math.abs(2 * (freq * t - math.floor(freq * t + 0.5))) - 1
    else -- sine
      raw = math.sin(2 * math.pi * freq * t)
    end
    local envelope = math.max(0, 1 - p) ^ 1.6
    data:setSample(i, raw * volume * envelope)
  end
  return love.audio.newSource(data, "static")
end

function sfx.load()
  sources = {}
  if not (love and love.audio and love.sound) then
    print("[sfx] audio unavailable, continuing silent")
    return
  end
  local ok, err = pcall(function()
    sources.catch = make_tone(660, 990, 0.16, "sine", 0.32)
    sources.hit = make_tone(170, 55, 0.32, "square", 0.34)
    sources.swap = make_tone(520, 1040, 0.24, "triangle", 0.32)
    sources.gameover = make_tone(330, 55, 0.7, "square", 0.3)
    sources.record = make_tone(880, 1760, 0.4, "sine", 0.32)
    sources.select = make_tone(700, 700, 0.07, "sine", 0.22)
  end)
  if not ok then
    print("[sfx] failed to synthesize sounds: " .. tostring(err))
    sources = {}
  end
end

function sfx.play(name, pitch)
  if sfx.muted then
    return
  end
  local source = sources[name]
  if source then
    source:stop()
    if source.setPitch then
      source:setPitch(pitch or 1)
    end
    source:play()
  end
end

return sfx
