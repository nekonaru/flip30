-- WAKTU LAMBAT: everything crawls at half speed. Easy mode, briefly.
return {
  name = "WAKTU LAMBAT",
  tags = { "speed" },
  hint = "Semua bergerak setengah kecepatan",
  apply = function(ctx)
    ctx.world.speed_mul = 0.5
  end,
  revert = function(ctx)
    ctx.world.speed_mul = 1
  end,
}
