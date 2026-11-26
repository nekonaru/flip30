-- ATURAN KUNCI: rule swaps happen every 45 seconds instead of 30.
return {
  name = "ATURAN KUNCI",
  tags = { "control" },
  hint = "Aturan bertahan lebih lama",
  apply = function(ctx)
    if ctx.rulemanager then
      ctx.rulemanager.rule_duration = 45
    end
  end,
  revert = function(ctx)
    if ctx.rulemanager then
      ctx.rulemanager.rule_duration = 30
    end
  end,
}
