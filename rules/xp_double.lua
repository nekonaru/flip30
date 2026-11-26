-- XP GANDA: double XP from runs.
return {
  name = "XP GANDA",
  tags = { "scoring" },
  hint = "XP dari sesi dikali dua",
  apply = function(ctx)
    ctx.world.xp_mul = 2
  end,
  revert = function(ctx)
    ctx.world.xp_mul = 1
  end,
}
