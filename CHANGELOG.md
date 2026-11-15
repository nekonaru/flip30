# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Docs aligned with the actual dev toolchain: README now documents the exact
  tools and versions used to build the game (LÖVE 11.5, LuaJIT 2.1, StyLua
  2.5.2, GitHub Actions CI, GitHub CLI, winget install commands) and notes
  that local commands and CI run the same tests and format check.
- CONTRIBUTING shows the exact `winget` commands used on Windows; RELEASING
  documents the checksum-verified release flow.

### Build

- `scripts/build.ps1` now appends a SHA-256 checksum table of the freshly
  built artifacts to `dist/RELEASE_NOTES.md`, so generated release notes
  double as a verification manifest. Release notes are written as UTF-8
  without a BOM.

## [1.0.0] - 2026-11-15

The first public release of Flip30.

### Added

- Core gameplay: 800x600 arena, 40x40 sticky-note player (`A`/`D`/arrows) with
  arena clamping, FOOD (+10) and ENEMY (-1 life) spawner with a difficulty
  curve that grows fall speed and spawn rate over time.
- Rule system: rules are single files in `rules/`, hot-swapped every 30
  seconds with a 2-second banner and 0.3x slow motion. Rules never repeat
  back-to-back and shared `tags` are rejected by the rule manager.
- The eight rules: KONTROL TERBALIK, GRAVITASI MATI, GRAVITASI NAIK,
  MUSUH JADI POIN, TUKAR WARNA, LAYAR GELAP, SEMUA 2X CEPAT, TIDAK BISA BERHENTI.
- High score persistence via `love.filesystem` (`highscore.txt`), tolerant of
  missing or corrupt files, with a "REKOR BARU!" celebration on the game over
  screen.
- Game states: menu, playing, game over — plus a thin rule-countdown progress
  bar, floating score popups, screen shake, red hit flash, and sparkle
  particles for pickups.
- Synthesized SFX (catch, hit, swap, game over, record, select) — zero audio
  assets required.
- Sandboxed mod support: extra rules in the save directory `rules/` folder run
  without `os`, `io`, or `love` access. Example mod included
  (`examples/rules/gerak_pelan.lua`). See `docs/modding.md`.
- Deterministic artwork mode: `love . --screenshot out.png --frames N
  [--force-rule "NAME"]`.
- 193-assertion headless test suite (LuaJIT) covering state restoration for
  every bundled rule, run in CI alongside a StyLua formatting check.
- Letterboxed rendering that scales to any window size (resizable, black bars).
- MIT license, brand artwork by the project author.

### Notes

- Platform: Windows/Linux/macOS via LÖVE 11.x. The `.love` archive and a
  fused Windows build are attached to the GitHub release.
- Music is intentionally out of scope; SFX are generated at load time.

[1.0.0]: https://github.com/nekonaru/flip30/releases/tag/v1.0.0
