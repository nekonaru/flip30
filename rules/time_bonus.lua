-- WAKTU TAMBAH: every catch adds a second to the rule timer.
return {
  name = "WAKTU TAMBAH",
  tags = { "control" },
  hint = "Tangkapan menambah waktu aturan",
  apply = function(ctx)
    ctx.world.time_bonus = 1
  end,
  revert = function(ctx)
    ctx.world.time_bonus = 0
  end,
}
