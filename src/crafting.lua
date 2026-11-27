-- src/crafting.lua
-- In-game rule crafting: combine a condition and an effect into a rule table.

local crafting = {}

crafting.conditions = {
  { id = "always", name = "SELALU" },
  { id = "low_life", name = "NYAWA SEDIKIT" },
  { id = "high_combo", name = "COMBO TINGGI" },
  { id = "late", name = "MENIT AKHIR" },
}

crafting.effects = {
  {
    id = "fast",
    name = "CEPAT",
    apply = function(w)
      w.speed_mul = 2
    end,
    revert = function(w)
      w.speed_mul = 1
    end,
  },
  {
    id = "slow",
    name = "LAMBAT",
    apply = function(w)
      w.speed_mul = 0.5
    end,
    revert = function(w)
      w.speed_mul = 1
    end,
  },
  {
    id = "double",
    name = "SKOR 2X",
    apply = function(w)
      w.score_mul = 2
    end,
    revert = function(w)
      w.score_mul = 1
    end,
  },
  {
    id = "magnet",
    name = "MAGNET",
    apply = function(w)
      w.magnet = true
    end,
    revert = function(w)
      w.magnet = false
    end,
  },
  {
    id = "ghost",
    name = "HANTU",
    apply = function(w)
      w.alpha = 0.35
    end,
    revert = function(w)
      w.alpha = 1
    end,
  },
}

function crafting.compile(condition_id, effect_id)
  local effect = nil
  for _, e in ipairs(crafting.effects) do
    if e.id == effect_id then
      effect = e
      break
    end
  end
  if not effect then
    return nil
  end
  return {
    name = "BUATAN",
    tags = { "craft" },
    hint = "Aturan buatan",
    apply = function(ctx)
      effect.apply(ctx.world)
    end,
    revert = function(ctx)
      effect.revert(ctx.world)
    end,
  }
end

return crafting
