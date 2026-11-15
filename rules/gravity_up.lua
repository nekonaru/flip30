-- GRAVITASI NAIK: objects fall from the bottom upwards.
return {
  name = "GRAVITASI NAIK",
  tags = { "gravity" },
  hint = "Objek jatuh dari bawah ke atas",
  apply = function(ctx)
    ctx.world.fall_direction = -1
  end,
  revert = function(ctx)
    ctx.world.fall_direction = 1
  end,
}
