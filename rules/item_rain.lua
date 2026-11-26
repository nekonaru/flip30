-- HUJAN ITEM: pickups become much more common.
return {
  name = "HUJAN ITEM",
  tags = { "spawn" },
  hint = "Lebih banyak item jatuh",
  apply = function(ctx)
    ctx.world.pickup_mul = 3
  end,
  revert = function(ctx)
    ctx.world.pickup_mul = 1
  end,
}
