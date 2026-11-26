-- HUJAN MUSUH: enemies become much more common.
return {
  name = "HUJAN MUSUH",
  tags = { "spawn" },
  hint = "Lebih banyak musuh jatuh",
  apply = function(ctx)
    ctx.world.enemy_chance_mul = 1.8
  end,
  revert = function(ctx)
    ctx.world.enemy_chance_mul = 1
  end,
}
