-- MUSUH LAMBAT: enemies move slower, food is unaffected.
return {
  name = "MUSUH LAMBAT",
  tags = { "speed" },
  hint = "Musuh bergerak lebih pelan",
  apply = function(ctx)
    ctx.world.enemy_speed_mul = 0.5
  end,
  revert = function(ctx)
    ctx.world.enemy_speed_mul = 1
  end,
}
