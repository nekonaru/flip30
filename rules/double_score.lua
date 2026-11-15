-- SKOR GANDA: every point earned is doubled. Enemies and escapes stay normal.
return {
  name = "SKOR GANDA",
  tags = { "scoring" },
  hint = "Semua poin dikali dua",
  apply = function(ctx)
    ctx.world.score_mul = 2
  end,
  revert = function(ctx)
    ctx.world.score_mul = 1
  end,
}
