-- KOMBO CEPAT: combo levels every two catches instead of four.
return {
  name = "KOMBO CEPAT",
  tags = { "scoring" },
  hint = "Combo naik tiap 2 tangkapan",
  apply = function(ctx)
    ctx.world.combo_step = 2
  end,
  revert = function(ctx)
    ctx.world.combo_step = 4
  end,
}
