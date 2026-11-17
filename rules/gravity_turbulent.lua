-- GRAVITASI TURBULEN: gravity flips randomly, without warning. Hold on.
return {
  name = "GRAVITASI TURBULEN",
  tags = { "gravity" },
  hint = "Arah jatuh berubah-ubah",
  apply = function(ctx)
    ctx.world.turbulent_timer = 2.0
  end,
  update = function(ctx, dt)
    ctx.world.turbulent_timer = (ctx.world.turbulent_timer or 2.0) - dt
    if ctx.world.turbulent_timer <= 0 then
      ctx.world.fall_direction = ctx.world.fall_direction * -1
      ctx.world.turbulent_timer = 2.0
    end
  end,
  revert = function(ctx)
    ctx.world.turbulent_timer = nil
    ctx.world.fall_direction = 1
  end,
}
