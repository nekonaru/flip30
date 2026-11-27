# Flip30 v3.0: Arena - Final Design

## Vision

Flip30 v3.0 turns the established single-player arcade loop into a complete arena game with a campaign, local multiplayer, boss encounters, rule crafting and progression. The game stays native: Lua 5.1, LÖVE 11.x, no external dependencies, 800x600 virtual canvas, 60 FPS target.

## Pillars

1. **Readable in ten seconds.** Every mode explains its goal on the select screen.
2. **Rules first.** Every rule is one Lua file with name, tags, hint, apply and revert. Crafted rules use the same contract.
3. **Deterministic.** A fixed 60 Hz step and a shared seeded RNG make seeds and replays reproducible.
4. **Progressive.** Chapters, enemy variants, hazards and bosses unlock over time.
5. **Local first.** No account, no backend, no network calls. Scores and profiles stay on the machine.

## Systems

### Campaign

Eight chapters with explicit goals. A chapter can require a score, a survival time, a boss count or a combination. Clearing a chapter advances the profile level and unlocks the next one. New Game+ restarts the campaign with all chapters available.

### Bosses

Five bosses with distinct HP, speed, burst and transparency. Boss Rush spawns one every two minutes. Each catch damages the active boss. Splitters spawn fast enemies when defeated. Armored bosses need two hits.

### Multiplayer

Co-op shares one arena. Versus splits scoring between two players. Hot-seat alternates turns. Player one uses A/D and Shift, player two uses arrows and right Shift. Winner is the higher score.

### Hazards

Laser sweeps start at 30 seconds, arena shrink at 90 seconds and blackout pulses at 150 seconds. Laser hits cost a life and enable the accessibility reduce-motion option.

### Crafting

A crafted rule combines one condition with one effect. Effects use the same world parameters as bundled rules, so apply and revert stay reversible. Crafted rules enter the rule pool immediately.

### Progression

XP and levels unlock skins and rules. Twenty achievements cover score, combo, survival, modes, bosses and modding. Three profiles store independent progress. Export and import use plain text files.

### Replay

Every fixed step records one input frame. A seed and a recorded run reproduce the same object spawns and rule swaps. Ghost playback draws the recorded player as a translucent box. Verification hashes compare run outcomes.

## Screens

Menu, mode select, settings, codex, achievements, profiles, replay, campaign, cosmetics, multiplayer, crafting, leaderboard, tournament, shop, pause and game over. All screens share the same chip-and-panel visual language.

## Done criteria

- 395 or more headless assertions pass under LuaJIT.
- StyLua reports no diff.
- A 20,000-frame soak reaches game over without errors.
- English and Indonesian README sections and table rows match.
- Release notes are bilingual and checksums match the published artifacts.

## Out of scope

Online accounts, cloud leaderboards, paid services, heavy assets and engines other than LÖVE.
