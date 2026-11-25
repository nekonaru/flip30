-- HUJAN EMAS: golden drops become much more frequent. Chase the good stuff.
return {
  name = "HUJAN EMAS",
  tags = { "spawn" },
  hint = "Lebih banyak makanan keemasan",
  apply = function(ctx)
    ctx.world.gold_mul = 4
  end,
  revert = function(ctx)
    ctx.world.gold_mul = 1
  end,
}
