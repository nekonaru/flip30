# Changelog

Changes to Flip30 are documented here. English is the source; Indonesian ([CHANGELOG.id.md](CHANGELOG.id.md)) is a faithful translation kept in sync.

## v1.1.0

The second release of Flip30, focused on feel, the interface, and the late game.

### New features

- **Two rules at two minutes.** Past the two minute mark, two rules are active at once; they never share a tag, and the HUD shows a "2x ATURAN" chip.
- **Pause.** Press P to pause the action and P again to resume; the world, rule timer and banner all freeze.
- **Sticky-note eyes.** The player's eyes track the direction of motion, with an idle bob and squash and stretch on impact.
- **Trauma shake and hit-stop.** Enemy hits fire trauma-based screen shake and a 60 ms hit-stop freeze.
- **Richer look.** Brand-derived palette, gradient arena, dot grid, vignette, glow halos for objects, chip-based HUD showing score, lives, and survival time, drifting silhouettes behind the menu, and a per-tag pitch for the rule-swap jingle.

### Improvements

- **Release tooling.** `scripts/build.ps1` parses the current changelog shape, emits bilingual English and Indonesian release notes with Install / Update and SHA-256 tables, and bundles the Indonesian docs into the Windows build.
- **Headless tests.** 197 assertions including dual-rule escalation coverage.

## v1.0.0

The first public release of Flip30.

### New features

- **Core gameplay.** An 800x600 arena with a 40x40 sticky-note player on A/D or arrow keys, FOOD worth +10 and ENEMY costing 1 life, and a difficulty curve that grows fall speed and spawn rate over time.
- **The rule system.** Rules are single Lua files in `rules/`, hot-swapped every 30 seconds with a two second banner and 0.3x slow motion. Rules never repeat back-to-back, and rules sharing a tag are never active together.
- **Eight rules.** KONTROL TERBALIK, GRAVITASI MATI, GRAVITASI NAIK, MUSUH JADI POIN, TUKAR WARNA, LAYAR GELAP, SEMUA 2X CEPAT, TIDAK BISA BERHENTI.
- **High score.** Stored locally in `highscore.txt`, with a "REKOR BARU!" celebration on a new record.
- **Game states.** Menu, playing, and game over, with hearts, a thin rule countdown bar, floating score popups, screen shake, and a red flash on hit.
- **Synthesized SFX.** Catch, hit, swap, gameover, record, and select, generated at load time; zero audio assets.
- **Sandboxed mods.** Extra rules in the save directory `rules/` folder run without `os`, `io`, or `love` access. Example mod included (`examples/rules/gerak_pelan.lua`).
- **Deterministic artwork mode.** `love . --screenshot out.png --frames N [--force-rule "NAME"]` produces the captures used in this repository.
- **Open source.** MIT license.

### Improvements

- **Letterboxed canvas.** The 800x600 virtual canvas is letterboxed and scaled to any window size.
- **Headless test suite.** 193 assertions under LuaJIT, run in CI together with a StyLua format check.
