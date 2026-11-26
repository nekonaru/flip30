# Changelog

Changes to Flip30 are documented here. English is the source; Indonesian ([CHANGELOG.id.md](CHANGELOG.id.md)) is a faithful translation kept in sync.

## v2.0.0

The biggest Flip30 update: seven modes, thirty rules, enemy variants, pickups, abilities, progression and replay.

### New features

- **Seven modes.** Classic, Blitz, Marathon, Zen, Chaos, Daily and Boss Rush, selectable with F1.
- **Thirty rules.** Thirteen new rules plus a draft system in Chaos where you pick one of three.
- **Enemy variants.** Fast, armored, splitter, phantom and bomb enemies unlock as you survive.
- **Pickups and abilities.** Magnet, shield, freeze, double, life, rule skip, screen clear. Dash with Shift and focus with Space.
- **Progression.** XP, levels, 20 achievements, three profiles, coin shop and export/import.
- **Screens.** Settings, codex, achievements, profiles and replay, plus a daily seed and run recording for ghost playback.
- **Web build script** and itch.io metadata.

## v1.8.0

Top-five scores, a fuller pause menu, and fixes from a deep source audit.

### New features

- **Top five scores.** `scores.txt` stores your five best scores; the stats panel on the menu shows all five.
- **Pause menu actions.** R restarts the run, Q or ESC returns to menu, P resumes, M mutes.

### Bug fixes

- **Mute did not reach music from the menu.** The M key now calls `game.setMute` everywhere, so music is muted too.
- **Stats panel showed raw streak as multiplier.** It now shows the multiplier awarded (streak 4 becomes x2).
- **Music source churn.** The loop source is created once and reused, instead of rebuilt at every restart.
- **Duplicate `game.setMute` definition.** Removed the dead copy.
- **Missing rule pitches.** SKOR GANDA, HUJAN EMAS and TANPA BATAS now retune the music too.

## v1.7.0

Two new rules, music that follows the rules, and small bug fixes from a deep audit.

### New features

- **Seventeen rules.** `TANPA BATAS` lets the player wrap around the arena edge instead of stopping. `HUJAN EMAS` quadruples the golden drop chance.
- **Music follows the rules.** The procedural loop now changes pitch when a new rule is applied, and stops when you leave the game.

### Bug fixes

- **SFX pitch leaked between sounds.** `sfx.play` now resets the pitch to x1 when no pitch is passed, so a high-pitched gold pickup no longer leaves later catch sounds high.
- **Music could not see the rules.** `game.ctx` now carries `rulemanager` and `music`, so the rule manager can ask the music module to retune.

## v1.6.0

Procedural music during the run.

### New features

- **Procedural music.** A generated 10-second loop playing during the run, with pitch shifts for the active rules (KONTROL TERBALIK is slightly low, WAKTU LAMBAT lower, SEMUA 2X CEPAT up). Nothing to set, it just sounds around your rules.

## v1.5.0

Two new rules, an in-game debug overlay, and a combo display fix.

### New features

- **Fifteen rules.** Two new rules: `HANTU` (objects turn translucent, tag vision) and `WAKTU LAMBAT` (everything crawls at half speed, tag speed).
- **Debug overlay.** `love . --debug` shows FPS, draw calls, canvas switches, live objects and texture memory. Press I to toggle it in game.

### Bug fixes

- **Combo display.** The menu and game over panels showed the raw streak as "COMBO TERBAIK xN"; they now show the multiplier that streak actually awards (a streak of 4 is x2, not x4).

## v1.4.0

Lifetime statistics, golden food, and many small joys layered over v1.3.0.

### New features

- **Lifetime statistics panel.** Press TAB on the menu to see total games, total time survived, total score, total food, best score, and best combo. Stats are stored locally and accumulate across runs.
- **Golden food.** A rare (7%) drop worth +50 points and exempt from TUKAR WARNA.
- **Combo milestones.** "COMBO x2 / x3 / x4 / x5" popups fire when your streak crosses a threshold.
- **Heartbeat pulse.** A red vignette pulses when only one life is left.
- **Animated score.** The score counter eases toward the real value instead of snapping.

### Bug fixes

- **Red flash stuck on game over.** The flash lifetime now decays even after the run ends, so the game-over screen is never tinted.

## v1.3.0

Thirteen rules, player-size rules, turbulent gravity, and bug fixes from the deep audit.

### New features

- **Thirteen rules.** Three new rules: `BESAR` (player becomes 72 px wide, tag control), `KECIL` (player becomes 22 px wide, tag control), and `GRAVITASI TURBULEN` (fall direction flips every 2 seconds, tag gravity).
- **Total games counter.** The main menu now shows how many runs you have started in total.

### Bug fixes

- **Player size leaks.** The player's width is restored to the 40 x 40 default on restart, otherwise `BESAR` and `KECIL` would carry their effect into a new run.
- **Escape penalty popup.** An enemy that leaves through the top during an upward-gravity rule shows the popup at the top, not at the bottom.

## v1.2.0

The biggest upgrade yet: combo scoring, two new rules, and the richest presentation so far.

### New features

- **Combo streak.** Every 4 catches in a row raises the score multiplier by one, up to x5. An enemy hit resets it. The best combo ever is saved locally and shown at game over.
- **Mute.** Press M to silence all SFX, anywhere.
- **Ten rules.** Two new rules: `HUJAN` (double object spawn rate, tag `spawn`) and `SKOR GANDA` (double score gains, tag `scoring`). Every rule now carries an in-game Indonesian description shown under the banner text.
- **Sticky note eyes.** The player's eyes track its direction of travel, with an idle bob, and squash and stretch on impacts.
- **Richer look.** Pre-rendered gradient arena with dot grid and vignette, additive glow halos, spinning or wobbling falling objects, chip-based HUD (score, lives, rule pill, survival timer, combo chip, mute chip, 2x chip in the two-rule phase), drifting silhouettes behind the menu, banner with description line and glowing border, and a pitch that varies per tag for the rule-swap jingle.

### Improvements

- **Release tooling.** `scripts/build.ps1` parses the current changelog shape, emits bilingual English and Indonesian release notes with Install / Update and SHA-256 tables, and bundles the Indonesian docs into the Windows build.
- **Headless tests.** 227 assertions including dual-rule escalation and combo-multiplier coverage.

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
