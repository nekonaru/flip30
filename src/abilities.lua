-- src/abilities.lua
-- Player abilities: dash and focus, both with cooldowns.

local abilities = {}

abilities.DASH_CD = 3
abilities.FOCUS_MAX = 4
abilities.FOCUS_REGEN = 0.35

function abilities.new()
  return { dash_cd = 0, focus = abilities.FOCUS_MAX, focus_active = false }
end

function abilities.reset(a)
  a.dash_cd = 0
  a.focus = abilities.FOCUS_MAX
  a.focus_active = false
end

function abilities.update(a, dt, focus_held)
  a.dash_cd = math.max(0, a.dash_cd - dt)
  if focus_held and a.focus > 0 then
    a.focus_active = true
    a.focus = math.max(0, a.focus - dt)
  else
    a.focus_active = false
    a.focus = math.min(abilities.FOCUS_MAX, a.focus + dt * abilities.FOCUS_REGEN)
  end
end

function abilities.try_dash(a)
  if a.dash_cd <= 0 then
    a.dash_cd = abilities.DASH_CD
    return true
  end
  return false
end

return abilities
