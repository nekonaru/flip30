-- GRAVITASI MATI: objects float down very slowly.
return {
  name = "GRAVITASI MATI",
  tags = { "gravity" },
  hint = "Objek melayang turun pelan",
  apply = function(ctx)
    ctx.world.gravity = 0.08
  end,
  revert = function(ctx)
    ctx.world.gravity = 1
  end,
}
