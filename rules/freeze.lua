-- FREEZE: objects freeze briefly when the rule starts.
return {
  name = "FREEZE",
  tags = { "speed" },
  hint = "Objek berhenti sejenak",
  apply = function(ctx)
    ctx.world.freeze_timer = 2
  end,
  revert = function(ctx)
    ctx.world.freeze_timer = 0
  end,
}
