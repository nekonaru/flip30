-- TUKAR WARNA: food and enemy colors are swapped. Behaviour is unchanged,
-- only the palette lies to your eyes.
return {
  name = "TUKAR WARNA",
  tags = { "colors" },
  hint = "Hijau dan merah tertukar",
  apply = function(ctx)
    ctx.world.swap_colors = true
  end,
  revert = function(ctx)
    ctx.world.swap_colors = false
  end,
}
