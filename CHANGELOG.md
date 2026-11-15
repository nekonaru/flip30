# Changelog

Changes to Flip30 are documented here. English is the source; Indonesian ([CHANGELOG.id.md](CHANGELOG.id.md)) is a faithful translation kept in sync.

## Unreleased

### Improvements

- **Docs follow one house style.** README and CHANGELOG now exist in English and Indonesian in sync, the release notes carry SHA-256 checksums and a toolchain list, and wording across the repository was trimmed to short, plain sentences.

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
