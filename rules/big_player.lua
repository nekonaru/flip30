-- BESAR: the sticky note grows wide, catching more but dodging less.
return {
  name = "BESAR",
  tags = { "control" },
  hint = "Player jadi lebih lebar",
  apply = function(ctx)
    ctx.player.w = 72
  end,
  revert = function(ctx)
    ctx.player.w = 40
  end,
}
