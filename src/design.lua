-- src/design.lua
-- Design tokens for Flip30 v4.0: colour ramps, spacing, radius,
-- motion durations and easing curves. All screens use these values.

local design = {}

design.spacing = { 4, 8, 12, 16, 24, 32, 48 }
design.radius = { chip = 4, button = 8, panel = 12, modal = 16 }
design.duration = { fast = 0.12, normal = 0.2, slow = 0.32, slower = 0.48 }
design.stagger = 0.04

local function clamp01(p)
  return math.max(0, math.min(1, p))
end

function design.ease_out(p)
  p = clamp01(p)
  return 1 - (1 - p) ^ 3
end

function design.ease_in_out(p)
  p = clamp01(p)
  if p < 0.5 then
    return 4 * p * p * p
  end
  return 1 - ((-2 * p + 2) ^ 3) / 2
end

function design.ease_back(p)
  p = clamp01(p)
  local c1 = 1.70158
  local c3 = c1 + 1
  local q = p - 1
  return 1 + c3 * q * q * q + c1 * q * q
end

-- Neutral ramp from near black to near white
design.neutral = {
  { 0.031, 0.040, 0.070 },
  { 0.055, 0.063, 0.090 },
  { 0.066, 0.078, 0.125 },
  { 0.10, 0.12, 0.18 },
  { 0.16, 0.195, 0.28 },
  { 0.30, 0.34, 0.42 },
  { 0.50, 0.55, 0.63 },
  { 0.62, 0.66, 0.75 },
  { 0.78, 0.82, 0.88 },
  { 0.93, 0.94, 0.97 },
}

design.semantic = {
  success = { 0.239, 0.859, 0.541 },
  warning = { 1.000, 0.824, 0.247 },
  danger = { 1.000, 0.302, 0.361 },
  info = { 0.122, 0.780, 0.937 },
}

design.grade_colors = {
  S = { 1.000, 0.824, 0.247 },
  A = { 0.239, 0.859, 0.541 },
  B = { 0.122, 0.780, 0.937 },
  C = { 0.62, 0.66, 0.75 },
  D = { 0.50, 0.55, 0.63 },
}

function design.grade(score, survived, combo)
  local points = score / 10 + survived / 5 + combo
  if points >= 100 then
    return "S"
  end
  if points >= 60 then
    return "A"
  end
  if points >= 35 then
    return "B"
  end
  if points >= 15 then
    return "C"
  end
  return "D"
end

return design
