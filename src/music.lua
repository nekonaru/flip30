-- src/music.lua
-- Procedural ambient music: a 10-second loop with kick, bass and pad,
-- pitched up or down depending on the active rules. No audio files needed.
-- Only the "playing" state runs music.

local music = {}

local CHANNEL_RATE = 44100
local LOOP_SECONDS = 10

music.muted = false

local pitches = {
  ["KONTROL TERBALIK"] = 0.85,
  ["GRAVITASI MATI"] = 0.95,
  ["GRAVITASI NAIK"] = 1.05,
  ["GRAVITASI TURBULEN"] = 1.0,
  ["MUSUH JADI POIN"] = 1.1,
  ["TUKAR WARNA"] = 1.15,
  ["HANTU"] = 1.0,
  ["HUJAN"] = 1.3,
  ["SEMUA 2X CEPAT"] = 1.5,
  ["WAKTU LAMBAT"] = 0.85,
  ["BESAR"] = 1.05,
  ["KECIL"] = 0.85,
  ["TIDAK BISA BERHENTI"] = 0.5,
  ["LAYAR GELAP"] = 0.75,
  default = 1.0,
}

local function note_gain(phase)
  -- Smooth envelope: rises fast, decays slowly, zero at the very end
  local s = math.min(1, phase / 0.08) * math.min(1, (1 - phase) / 0.12 + 0.4)
  return s
end

local function band(freq, speed)
  local a = 1.0 / (1.0 + freq / 24)
  return math.sin(freq * speed) + a * math.sin(freq * 0.99 * speed) + math.sin(freq * 0.5 * speed)
end

local function generate_loop(pitch)
  local n = math.floor(CHANNEL_RATE * LOOP_SECONDS)
  local sd = love.sound.newSoundData(n, CHANNEL_RATE, 16, 1)
  for i = 0, n - 1 do
    local t = i / CHANNEL_RATE
    local phase = (i % math.floor(CHANNEL_RATE * LOOP_SECONDS)) / CHANNEL_RATE
    local beat = math.floor((phase * 8))
    local kick = math.max(0, 1 - math.abs((phase % 0.25) - 0.06) / 0.10)
    -- bass line
    local bass = math.sin(2 * math.pi * 30 * pitch * t) + 0.5 * math.sin(2 * math.pi * 62 * pitch * t)
    -- padded pad
    local pad = 0.5 * band(pitch * 200, phase * 6) + 0.25 * band(pitch * 300, phase * 11)
    local sample = 0
    if beat % 2 == 0 and kick > 0 then
      sample = kick * (bass + pad)
    end
    sample = sample + bass * 0.2 + pad * 0.3
    -- anti-click fades near the loop boundary
    local g = note_gain(phase / LOOP_SECONDS)
    sd:setSample(i, sample * 0.22 * g)
  end
  return sd
end

function music.load()
  if not (love and love.audio and love.sound) then
    return false
  end
  local ok, err = pcall(function()
    music._base = generate_loop(1)
  end)
  if not ok then
    print("[music] failed to synthesize loop: " .. tostring(err))
    return false
  end
  return true
end

local function pitch_for(ctx)
  if not music._base then
    return 1
  end
  local pitch = 1
  if ctx and ctx.rulemanager and ctx.rulemanager.activeName then
    local name = ctx.rulemanager.activeName()
    if name and pitches[name] then
      pitch = pitch * pitches[name]
    end
  end
  return pitch
end

function music.play(ctx)
  if music.muted then
    return
  end
  if not music._base or not music._playing then
    music._src = love.audio.newSource(music._base, "stream")
    music._src:setLooping(true)
    music._src:setVolume(0.18)
    music._playing = true
  end
  music._src:stop()
  music._src:setPitch(pitch_for(ctx))
  music._src:play()
end

function music.stop()
  if music._src then
    music._src:pause()
  end
  music._playing = false
end

function music.resume(ctx)
  if not music._playing then
    music.play(ctx)
  end
end

return music
