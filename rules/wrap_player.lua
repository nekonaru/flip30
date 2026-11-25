-- TANPA BATAS: the sticky note wraps around the arena instead of stopping.
return {
  name = "TANPA BATAS",
  tags = { "control" },
  hint = "Player bisa lewat tepi layar",
  apply = function(ctx)
    ctx.world.wrap = true
  end,
  revert = function(ctx)
    ctx.world.wrap = false
  end,
}
