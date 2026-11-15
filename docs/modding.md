# Modding Flip30

Flip30 was designed so that **adding a rule never means editing the engine**.
A rule is one Lua file. This guide shows how to write, install, and debug one.

## The rule contract

```lua
return {
  name = "KONTROL TERBALIK",   -- shown on the banner and in the HUD
  tags = { "control" },        -- prevents conflicting rules being active together
  apply = function(ctx)
    ctx.player.dir = -1
  end,
  revert = function(ctx)
    ctx.player.dir = 1
  end,
  -- optional: called every frame while the rule is active
  update = function(ctx, dt) end,
  -- optional: drawn above the arena, below the HUD
  draw = function(ctx) end,
}
```

| Field | Required | Meaning |
| --- | --- | --- |
| `name` | yes | Uppercase display name, e.g. `"GRAVITASI MATI"`. |
| `tags` | recommended | Any non-empty table of strings. Two rules sharing a tag are never active at the same time. Conventional tags: `control`, `gravity`, `speed`, `scoring`, `colors`, `vision`. |
| `apply(ctx)` | yes | Apply the effect. Called inside `pcall`, errors are logged and the rule is skipped (and reverted). |
| `revert(ctx)` | yes | **Undo everything `apply` did.** Must be the exact inverse, or later game states leak. |
| `update(ctx, dt)` | no | Per-frame logic while active. Errors are logged and skipped. |
| `draw(ctx)` | no | Draw above the arena, below the HUD/banner. Errors are logged and skipped. |

### The `ctx` table

| Field | Type | Notes |
| --- | --- | --- |
| `ctx.player` | table | `x`, `y`, `w`, `h`, `speed`, `dir`, `always_move`, `last_dir`. Mutate behavior fields (`dir`, `always_move`), not geometry. |
| `ctx.world` | table | `fall_speed`, `fall_speed_growth`, `spawn_interval`, `speed_mul`, `gravity`, `fall_direction`, `enemy_gives_points`, `enemy_points`, `enemy_escape_penalty`, `enemy_life_damage`, `swap_colors`, `darkness`, `elapsed`. All numbers/booleans, so snapshot and restore whatever you touch. |
| `ctx.spawner` | table | Spawn table: `objects` (array), `timer`, `FOOD`, `ENEMY`. |
| `ctx.ui` | table | `ui.showBanner(text)`, `ui.addPopup(x, y, text, color)`. |
| `ctx.sfx` | table or nil | `sfx.play("catch" \| "hit" \| "swap" \| "gameover" \| "record" \| "select")`. |

## The golden rule: revert perfectly

The engine calls `apply` → (30 seconds) → `revert` on every swap. If `revert`
doesn't restore the pre-rule state exactly, the next rules inherit a poisoned
world and bugs become impossible to reproduce.

```lua
-- WRONG: applies twice, never restores
apply = function(ctx) ctx.world.gravity = ctx.world.gravity * 0.5 end,

-- RIGHT: absolute values, exact inverse
apply = function(ctx) ctx.world.gravity = 0.5 end,
revert = function(ctx) ctx.world.gravity = 1 end,
```

## Where mods live

Mods are plain `.lua` files placed in a `rules/` folder **inside the LÖVE
save directory**, not in the game's source folder:

| Platform | Save directory (identity is `flip30`) |
| --- | --- |
| Windows | `%APPDATA%\love\flip30\rules\` |
| Linux | `~/.local/share/love/flip30/rules/` |
| macOS | `~/Library/Application Support/LOVE/flip30/rules/` |

Create the `rules` folder if it doesn't exist. After copying a mod, restart the
game. The console (or the log) prints `[modloader] mod loaded: rules/<file>.lua`.

- Mod files **override** bundled rules with the same filename.
- The number of loaded rules is printed at startup: `[rulemanager] N rule(s) loaded`.

## The sandbox

Mods run inside a restricted environment:

- **Available:** `math`, `string`, `table`, `pairs`/`ipairs`/`next`, `type`,
  `tostring`, `tonumber`, `pcall`/`xpcall`/`error`/`assert`, `setmetatable`,
  `raw{get,set,equal}`, `select`, `unpack`, `print` (goes to the console).
- **Not available:** `os`, `io`, `require`, `love` (no graphics, no filesystem!),
  `debug`, `package`, `load`/`loadstring`/`dofile`/`loadfile`.

A mod that tries to escape simply fails validation or throws inside `pcall` and
is skipped. It cannot crash the game or read your files.

## Example: GERAK PELAN

See [`examples/rules/gerak_pelan.lua`](../examples/rules/gerak_pelan.lua):

```lua
return {
  name = "GERAK PELAN",
  tags = { "speed" },
  apply = function(ctx) ctx.world.speed_mul = 0.5 end,
  revert = function(ctx) ctx.world.speed_mul = 1 end,
}
```

Half speed for objects, spawn rate **and** the player. `speed` tag means it can
never be active alongside `SEMUA 2X CEPAT`.

## Testing your mod without leaving the editor

```sh
love . --force-rule "GERAK PELAN"
```

forces your rule to be applied immediately on launch. Combine with
`--screenshot out.png --frames 120` for deterministic verification.

To run the headless suite with your rule included, add it to
`bundled_rule_files` in `tests/headless_tests.lua` and:

```sh
luajit tests/headless_tests.lua
```

The suite asserts that every listed rule's `apply` → `revert` restores the
exact pre-rule state, the single most important property of a rule.
