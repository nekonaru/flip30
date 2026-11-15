-- SEMUA 2X CEPAT: everything moves twice as fast: fall speed, spawn
-- rate, player speed. Hold onto your hat.
return {
  name = "SEMUA 2X CEPAT",
  tags = { "speed" },
  hint = "Semua bergerak 2x lebih cepat",
  apply = function(ctx)
    ctx.world.speed_mul = 2
  end,
  revert = function(ctx)
    ctx.world.speed_mul = 1
  end,
}
