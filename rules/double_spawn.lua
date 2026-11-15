-- HUJAN: objects rain down twice as fast. Timing becomes much harder.
return {
  name = "HUJAN",
  tags = { "spawn" },
  hint = "Objek jatuh dua kali lipat",
  apply = function(ctx)
    ctx.world.spawn_rate_mul = 2
  end,
  revert = function(ctx)
    ctx.world.spawn_rate_mul = 1
  end,
}
