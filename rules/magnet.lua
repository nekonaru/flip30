-- MAGNET: food drifts toward the player.
return {
  name = "MAGNET",
  tags = { "control" },
  hint = "Makanan ditarik ke player",
  apply = function(ctx)
    ctx.world.magnet = true
  end,
  revert = function(ctx)
    ctx.world.magnet = false
  end,
}
