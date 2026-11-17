-- KECIL: the sticky note shrinks to a tiny target, harder to catch.
return {
  name = "KECIL",
  tags = { "control" },
  hint = "Player jadi lebih kecil",
  apply = function(ctx)
    ctx.player.w = 22
  end,
  revert = function(ctx)
    ctx.player.w = 40
  end,
}
