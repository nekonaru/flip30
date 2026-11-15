# Project

| Variable | Value |
| --- | --- |
| PROJECT_NAME | Flip30 |
| REPO | nekonaru/flip30 |
| AUTHOR_NAME | Nicolas Dwi Dharma |
| AUTHOR_GITHUB | nekonaru |
| PROJECT_KIND | app |
| STACK | LÖVE 11.5 (Lua 5.1 / LuaJIT) |
| PLATFORMS | Windows, Linux, macOS |
| MIN_OS | Any OS supported by LÖVE 11.5 (Windows, Linux, macOS) |
| DEFAULT_BRANCH | main |
| LICENSE | MIT |
| UI_LANGUAGES | Bahasa Indonesia |
| VERIFICATION | local-and-ci |
| PIPELINE | pr |

## Run

- `love .` starts the game.
- `luajit tests/headless_tests.lua` runs the headless test suite (must pass).
- `stylua --check .` checks formatting (CI enforces it).
- `love . --screenshot out.png --frames N [--force-rule "NAME"]` captures deterministic artwork.

UI text is in Bahasa Indonesia. Code, comments, commit messages, and docs source are English; Indonesian is a translation kept in sync (`README.id.md`, `CHANGELOG.id.md`).

## Conventions

- Conventional Commits, one logical change per commit, push after every commit.
- Rules are single files in `rules/`; `apply` and `revert` must be exact inverses.
- Tests live in `tests/headless_tests.lua`; register every new rule in `bundled_rule_files`.
