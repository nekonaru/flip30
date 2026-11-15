-- MUSUH JADI POIN: touching enemies scores +15 instead of costing a life.
-- Enemies that leave the screen cost -5 score instead (clamped at 0).
return {
  name = "MUSUH JADI POIN",
  tags = { "scoring" },
  hint = "Musuh = +15, lari = -5",
  apply = function(ctx)
    ctx.world.enemy_gives_points = true
  end,
  revert = function(ctx)
    ctx.world.enemy_gives_points = false
  end,
}
