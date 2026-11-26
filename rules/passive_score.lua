-- PENGHASIL: score trickles in every second.
return {
  name = "PENGHASIL",
  tags = { "scoring" },
  hint = "Skor bertambah tiap detik",
  apply = function(ctx)
    ctx.world.score_per_sec = 5
  end,
  revert = function(ctx)
    ctx.world.score_per_sec = 0
  end,
}
