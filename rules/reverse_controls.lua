-- KONTROL TERBALIK: left becomes right and vice versa.
return {
  name = "KONTROL TERBALIK",
  tags = { "control" },
  apply = function(ctx)
    ctx.player.dir = -1
  end,
  revert = function(ctx)
    ctx.player.dir = 1
  end,
}
