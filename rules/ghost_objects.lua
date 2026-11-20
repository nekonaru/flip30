-- HANTU: objects become translucent ghosts. Still deadly, just harder to see.
return {
  name = "HANTU",
  tags = { "vision" },
  hint = "Objek jadi tembus pandang",
  apply = function(ctx)
    ctx.world.alpha = 0.35
  end,
  revert = function(ctx)
    ctx.world.alpha = 1
  end,
}
