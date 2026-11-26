-- KOIN GANDA: double coins from runs.
return {
  name = "KOIN GANDA",
  tags = { "scoring" },
  hint = "Koin dari sesi dikali dua",
  apply = function(ctx)
    ctx.world.coin_mul = 2
  end,
  revert = function(ctx)
    ctx.world.coin_mul = 1
  end,
}
