<div align="center">
  <img src="assets/brand/icon-512.png" alt="Flip30 logo" width="120" />
  <h1>Flip30: The Rules Change Every 30 Seconds</h1>
  <p><b>Catch the food, dodge the enemies, and adapt every 30 seconds<br/>as the rules flip out from under you.</b></p>

  <a href="https://github.com/nekonaru/flip30/releases"><img src="https://img.shields.io/github/v/release/nekonaru/flip30?style=flat-square&color=blue" alt="Release" /></a>
  <a href="https://github.com/nekonaru/flip30/actions/workflows/ci.yml"><img src="https://github.com/nekonaru/flip30/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/L%C3%96VE-11.5-00a2ff?style=flat-square" alt="LÖVE 11.5" />
  <img src="https://img.shields.io/badge/Lua-LuaJIT-000080?style=flat-square" alt="LuaJIT" />
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-3DDC84?style=flat-square" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square" alt="Status" />
</div>

<br />

**English** | [Bahasa Indonesia](README.id.md)

> [!NOTE]
> Flip30 runs on LÖVE 11.5, a free, open-source 2D engine. To play, you need the prebuilt Windows download (includes everything) or a one-time LÖVE 11.5 install.

---

## Table of Contents

- [About](#about)
- [Screenshots](#screenshots)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Continuous Integration](#continuous-integration)
- [FAQ](#faq)
- [Author](#author)
- [License](#license)

---

## About

**Flip30** is a small arcade survival game about adapting faster than the game can change. You slide a sticky note along the bottom of the screen, catching food and dodging enemies, and every 30 seconds the entire ruleset is swapped for a random new one. Everything runs locally with no account and no internet connection.

> _"The rules change every 30 seconds."_

---

## Screenshots

| Menu | Gameplay |
| --- | --- |
| ![Flip30 main menu](assets/screenshots/menu.png) | ![Flip30 gameplay with HUD, hearts, and the rule timer](assets/screenshots/gameplay.png) |

---

## Features

### Core gameplay

| Feature | Description |
| --- | --- |
| **Player** | Slide the 40x40 sticky note with A/D or the arrow keys, clamped to the arena. Eyes track where it is heading |
| **Objects** | Green food is +10 points. Golden food is a rare drop worth +50, exempt from TUKAR WARNA. Red enemies cost 1 life, played on an 800x600 canvas |
| **Difficulty** | Fall speed and spawn rate ramp up over time; you get three lives per run |
| **High score** | Best score saved locally to `highscore.txt`, celebrated on a new record |
| **Top five** | The stats panel shows your five best scores from `scores.txt` |
| **Survival timer** | The HUD shows how long you have lasted, mm:ss |
| **Combo** | Every 4 catches in a row raises the multiplier, up to x5; an enemy hit resets it |
| **Statistics** | Press TAB on the menu to see lifetime stats: total games, total time survived, total score, total food, best score, best combo |
| **Two rules at two minutes** | Past 2:00, two rules run at once; they never share a tag |
| **Pause** | Press P to freeze; R restarts, Q or ESC returns to menu |
| **Mute** | Press M to silence SFX, anywhere |

### Rules on a timer

| Feature | Description |
| --- | --- |
| **Thirty second flips** | Every 30 seconds the active rule is reverted and a random one is applied |
| **Seventeen rules** | KONTROL TERBALIK, GRAVITASI MATI, GRAVITASI NAIK, MUSUH JADI POIN, TUKAR WARNA, LAYAR GELAP, SEMUA 2X CEPAT, TIDAK BISA BERHENTI, HUJAN, SKOR GANDA, BESAR, KECIL, GRAVITASI TURBULEN, HANTU, WAKTU LAMBAT, TANPA BATAS, HUJAN EMAS |
| **Fair picks** | Never the same rule twice in a row; rules sharing a tag are never active together |
| **Announcement banner** | Big two second banner with a description line while the action slows to 0.3x |
| **Countdown bar** | Thin timer bar across the top of the screen |

### Look and feel

| Feature | Description |
| --- | --- |
| **Juice** | Sparkles, screen shake, floating score popups, animated score tally, a red flash when you are hit, and a heartbeat pulse when only one life remains |
| **Combo milestones** | "COMBO x2 / x3 / x4 / x5" popups fire when your streak crosses a threshold |
| **Sound** | Synthesized SFX generated at load time, no audio files needed |

### Modding

| Feature | Description |
| --- | --- |
| **Rules as data** | Each rule is one Lua file in `rules/`, no engine changes needed |
| **Sandboxed mods** | Extra rules in the save directory `rules/` folder run without `os`, `io`, or `love` access |
| **Example mod** | `examples/rules/gerak_pelan.lua`, a half-speed rule to copy as a starting point |

### Development

| Feature | Description |
| --- | --- |
| **Headless tests** | 279 assertions run under LuaJIT in CI |
| **Formatted code** | StyLua enforced locally and in CI |
| **Artwork mode** | Deterministic `--screenshot` captures used for this README |
| **Debug overlay** | `love . --debug` shows FPS, objects, canvas switches; press I to toggle |
| **Procedural music** | Generated loop sounding like the rule range in the key (see below) |
| **Responsive canvas** | 800x600 virtual canvas letterboxed to any window size |
| **Open source** | MIT license |

---

## Requirements

| Dependency | Minimum Version | Notes |
| --- | --- | --- |
| **LÖVE** | 11.x (11.5 tested) | Required to run from source and to open the `.love` build |
| **Windows** | 7 or later, 64-bit | Prebuilt download includes everything, no LÖVE install needed |
| **Linux / macOS** | any supported version | Requires installing LÖVE once |
| **Keyboard** | A/D or arrow keys, Enter, Esc | Mouse not required |
| **Account** | None | High score stays on your machine |

> [!TIP]
> If you only want to play, download the prebuilt build from the [Releases](https://github.com/nekonaru/flip30/releases) page. You need nothing else.

### Never used a terminal? Start here

<details>
<summary><b>How to open a terminal on Windows</b></summary>

1. Press the **Windows** key, type `PowerShell`, then press **Enter**
2. A window opens. That is where you type commands
3. Every command in this guide is typed in that window, followed by **Enter**

</details>

---

## Installation

### Option A: Download the prebuilt build (easiest)

1. Open the [Releases](https://github.com/nekonaru/flip30/releases) page
2. Download `flip30-1.8.0-win64.zip` on Windows, or `flip30-1.8.0.love` on other platforms
3. Windows: extract the zip anywhere and run `Flip30.exe`. Other platforms: install LÖVE 11.5, then run `love flip30-1.8.0.love`

> [!IMPORTANT]
> Use `flip30-1.8.0-win64.zip` on Windows. Use `flip30-1.8.0.love` only with a separate LÖVE 11.5 install.

### Option B: Build from source (for development / to read or change the code)

#### 1. Get the project code

<details>
<summary><b>I have Git installed</b></summary>

```bash
git clone https://github.com/nekonaru/flip30.git
cd flip30
```

</details>

<details>
<summary><b>I don't have Git</b></summary>

1. Open the repository page on GitHub
2. Click the green **`Code`** button, then choose **`Download ZIP`**
3. Extract the ZIP to a folder of your choice
4. In the terminal, go into the extracted folder, for example:

```bash
cd flip30-main
```

</details>

#### 2. Install the dependencies and verify

Install LÖVE 11.5, then check that the version prints correctly:

```powershell
love --version
```

On Windows, the fastest install is `winget install --id Love2d.Love2d -e`.

> [!IMPORTANT]
> `love --version` must print `LOVE 11.x` (11.5 recommended) before you continue.

#### 3. Run it

```sh
love .
```

The menu opens and the game is fully playable. To produce the release artifacts (`.love` archive and Windows build), run `scripts/build.ps1 -Version 1.8.0` on Windows.

---

## Usage

### First launch

1. Open the game with `love .` or via the prebuilt download
2. The menu appears. Press **Enter** or **Space** to start
3. A normal game begins. The first rule swap happens at t = 30 seconds

> [!NOTE]
> The UI text is in Bahasa Indonesia. The game is playable without reading it: green is good, red is bad.

### Everyday use

- **Move**: A/D or the arrow keys
- **Pause**: P to pause, P to resume; ESC to menu
- **Mute**: M, anywhere
- **Catch food**: green note, +10 points, and a combo streak builds up to x5
- **Avoid enemies**: red triangle, -1 life, you start with 3
- **Survive**: the longer you last, the faster the game gets; past 2:00 two rules can run at once
- **Restart**: Enter or Space on the game over screen; Esc returns to the menu or quits
- **High score**: shown on the menu and the game over screen; saved automatically
- **Stats**: TAB on the menu opens the lifetime statistics panel
- **Golden food**: a rare, exempt-from-color-swap pickup worth +50 points

---

## Project Structure

```
flip30/
  main.lua            # LÖVE entry point, --screenshot artwork mode, --force-rule
  conf.lua            # Window, identity, icon, LÖVE version
  src/
    game.lua          # State machine (menu, playing, gameover), letterboxing
    player.lua        # 40x40 sticky-note movement
    spawner.lua       # FOOD/ENEMY spawns, difficulty curve, collisions
    world.lua         # Mutable world parameters and difficulty scaling
    rulemanager.lua   # Rule loading, selection, apply/revert, 30s timer
    modloader.lua     # Sandboxed mod loading from the save directory
    ui.lua            # HUD, banner, popups, hearts, menu, game over
    storage.lua       # High score via love.filesystem (highscore.txt)
    particles.lua     # Sparkle bursts, generated sprite
    sfx.lua           # Synthesized sound effects, no audio files
    music.lua         # Procedural 10s loop, pitch shifts per active rule
    debugpanel.lua    # FPS/objects dev overlay (love . --debug)
  rules/              # One file per rule, hot-swapped every 30 seconds
  assets/
    brand/            # Logo, icon, monochrome artwork
    screenshots/      # In-game captures from the screenshot mode
  examples/rules/     # Example mod to copy into the save directory
  tests/              # Headless LuaJIT test suite
  scripts/            # build.ps1 and build.sh release artifact builders
  docs/               # Modding guide, release process, PRD
  stylua.toml         # Formatter config, used locally and in CI
  README.md           # Documentation (English)
  README.id.md        # Documentation (Bahasa Indonesia)
```

---

## Development

### Adding a new rule

1. Create `rules/my_rule.lua` with `name`, `tags`, `apply`, and `revert`
2. `apply` and `revert` must be exact inverses of each other
3. Add the file to `bundled_rule_files` in `tests/headless_tests.lua`
4. Run `luajit tests/headless_tests.lua`

> [!NOTE]
> The engine loads every rule in `rules/` automatically; only the four steps above are needed.

### Regenerating the screenshots

```sh
love . --screenshot shots/menu.png --frames 0
love . --screenshot shots/gameplay.png --frames 260
love . --screenshot shots/dark.png --frames 60 --force-rule "LAYAR GELAP"
```

### Debug overlay

```sh
love . --debug
```

Press I to toggle the overlay. It shows FPS, draw calls, canvas switches, live objects and texture memory.

---

## Testing

Verification before every push:

```bash
luajit tests/headless_tests.lua
stylua --check .
```

| Check | Requirement |
| --- | --- |
| `luajit tests/headless_tests.lua` | All 279 assertions pass |
| `stylua --check .` | No output (no diffs) |

Formatting is configured in `stylua.toml`.

---

## Continuous Integration

| Workflow | Purpose |
| --- | --- |
| `ci.yml` | Runs the headless test suite (LuaJIT) and `stylua --check .` on every push and pull request |

The local commands are the same three as CI, so green locally means green on GitHub.

---

## FAQ

<details>
<summary><b>Why does the game keep changing the rules?</b></summary>

That is the game. Every 30 seconds a different rule is applied, and the whole point is learning a new ruleset fast.

</details>

<details>
<summary><b>Where is my high score stored?</b></summary>

In `highscore.txt` inside the app's save directory (for example `%APPDATA%\love\flip30` on Windows). It survives closing the game.

</details>

<details>
<summary><b>Can I add my own rules?</b></summary>

Yes. Put a `.lua` file in the `rules` folder inside the save directory. See [docs/modding.md](docs/modding.md) for the rule contract and a complete example.

</details>

<details>
<summary><b>Does the game need the internet?</b></summary>

No. Everything runs locally, including the high score.

</details>

<details>
<summary><b>How do I report a bug?</b></summary>

Open an issue with your platform, the output of `love --version`, and whether any mods are loaded.

</details>

---

## Author

<div align="center">

| [![Nicolas Dwi Dharma](https://github.com/nekonaru.png?size=100)](https://github.com/nekonaru) |
|:---:|
| **Nicolas Dwi Dharma** |
| [github.com/nekonaru](https://github.com/nekonaru) |

</div>

---

## License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for more information.
