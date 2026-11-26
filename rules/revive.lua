-- NYAWA CADANGAN: one free revive when lives run out.
return {
  name = "NYAWA CADANGAN",
  tags = { "control" },
  hint = "Satu nyawa gratis saat habis",
  apply = function(ctx)
    ctx.world.revive = 1
  end,
  revert = function(ctx)
    ctx.world.revive = 0
  end,
}
