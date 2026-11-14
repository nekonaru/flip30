-- TIDAK BISA BERHENTI: the player can never stop moving; they keep
-- sliding in the last direction they chose.
return {
  name = "TIDAK BISA BERHENTI",
  tags = { "control" },
  apply = function(ctx)
    ctx.player.always_move = true
    ctx.player.last_dir = ctx.player.last_dir or 1
  end,
  revert = function(ctx)
    ctx.player.always_move = false
  end,
}
