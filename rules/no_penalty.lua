-- AMAN: enemies leaving the screen no longer cost score.
return {
  name = "AMAN",
  tags = { "scoring" },
  hint = "Musuh lolos tanpa pinalti",
  apply = function(ctx)
    ctx.world.no_penalty = true
  end,
  revert = function(ctx)
    ctx.world.no_penalty = false
  end,
}
