-- KONTROL TERBALIK: left becomes right and vice versa.
return {
  name = "KONTROL TERBALIK",
  tags = { "control" },
  hint = "Kiri jadi kanan, kanan jadi kiri",
  apply = function(ctx)
    ctx.player.dir = -1
  end,
  revert = function(ctx)
    ctx.player.dir = 1
  end,
}
