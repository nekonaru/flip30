-- Example Flip30 mod: GERAK PELAN
-- Install: copy this file into the `rules/` folder inside your LÖVE save
-- directory (see docs/modding.md for the exact path per platform).
--
-- Mods must return a table with `name`, `apply`, `revert` and may include
-- `tags`, `update`, `draw`. They run in a sandbox without `os`, `io` or
-- `love`, so they can only touch the game through the `ctx` object.

return {
  -- Shown on the banner and in the HUD.
  name = "GERAK PELAN",

  -- Tags prevent two rules that fight over the same subsystem from being
  -- active together. Common tags: control, gravity, speed, scoring,
  -- colors, vision.
  tags = { "speed" },

  apply = function(ctx)
    -- Half speed for objects, spawn rate AND the player.
    ctx.world.speed_mul = 0.5
  end,

  revert = function(ctx)
    -- MUST restore the original value, or the next rules inherit the mess.
    ctx.world.speed_mul = 1
  end,
}
