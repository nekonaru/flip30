-- src/anim.lua
-- Lightweight tween manager. Stores active tweens and advances them with
-- real time so pause and hit-stop never freeze UI feedback.

local anim = {}

anim.tweens = {}

local function get_target(target, key)
  local value = target[key]
  return value or 0
end

function anim.to(target, key, to_value, duration, easing, on_done)
  table.insert(anim.tweens, {
    target = target,
    key = key,
    from = get_target(target, key),
    to = to_value,
    time = 0,
    duration = math.max(0.001, duration or 0.2),
    easing = easing or function(p)
      return p
    end,
    on_done = on_done,
  })
end

function anim.update(dt)
  for i = #anim.tweens, 1, -1 do
    local tw = anim.tweens[i]
    tw.time = tw.time + dt
    local p = math.min(1, tw.time / tw.duration)
    local eased = tw.easing(p)
    tw.target[tw.key] = tw.from + (tw.to - tw.from) * eased
    if p >= 1 then
      table.remove(anim.tweens, i)
      if tw.on_done then
        tw.on_done()
      end
    end
  end
end

function anim.clear()
  anim.tweens = {}
end

function anim.count()
  return #anim.tweens
end

return anim
