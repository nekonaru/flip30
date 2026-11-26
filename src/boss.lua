-- src/boss.lua
-- Boss encounters every two minutes in BOSS RUSH. Defeat by catching food.

local boss = {}

boss.HP = 10
boss.INTERVAL = 120

function boss.new()
  return { active = false, hp = 0, count = 0, next = boss.INTERVAL }
end

function boss.update(b, elapsed, on_start)
  if not b.active and elapsed >= b.next then
    b.active = true
    b.hp = boss.HP
    b.count = b.count + 1
    b.next = elapsed + boss.INTERVAL
    if on_start then
      on_start(b)
    end
  end
end

function boss.hit(b)
  if not b.active then
    return false
  end
  b.hp = b.hp - 1
  if b.hp <= 0 then
    b.active = false
    return true
  end
  return false
end

return boss
