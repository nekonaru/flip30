# Contributing to Flip30

Thanks for helping make Flip30 better! This document explains how to set up
your environment, our code style, and what we look for in pull requests.

## Development setup

1. Install [LÖVE](https://love2d.org) 11.5.
2. Install [LuaJIT](https://luajit.org) 2.1, the same Lua VM LÖVE ships, for the
   the headless test suite.
3. Install [StyLua](https://github.com/JohnnyMorganz/StyLua) 2.x for formatting
   (config: `stylua.toml`).
4. On Windows, steps 1-3 are three commands:

   ```powershell
   winget install --id Love2d.Love2d -e
   winget install --id DEVCOM.LuaJIT -e
   winget install --id JohnnyMorganz.StyLua -e
   ```

5. Clone and run:

   ```sh
   git clone https://github.com/nekonaru/flip30.git
   cd flip30
   love .
   ```

CI (`.github/workflows/ci.yml`) runs exactly the local commands, the test
suite and `stylua --check`, so green locally means green on GitHub.

## Before you commit

```sh
luajit tests/headless_tests.lua   # must pass
stylua .                          # formats in place
love .                            # smoke-test: menu → play → gameover
```

## Code style

- **Lua 5.1/LuaJIT** (what LÖVE ships). No 5.2+ only syntax.
- **snake_case** for variables and functions.
- **Comments in English**, short and only where they add information.
- **No new global variables.** Pass state explicitly.
- Formatting is enforced by StyLua (`stylua.toml`); CI checks it.
- Keep the folder structure from the PRD (`src/`, `rules/`, `assets/`, ...).

## Adding a rule (the easiest contribution)

Rules are self-contained files in `rules/`. Read the
[rule contract](docs/modding.md#the-rule-contract). In short:

1. Create `rules/my_rule.lua` returning a table with `name`, `tags`, `apply`,
   `revert` (and optionally `update` / `draw`).
2. `apply` and `revert` **must** be inverse operations. Restoring state is not
   optional: leaked state breaks every later rule.
3. Add the file to the `bundled_rule_files` list in `tests/headless_tests.lua`.
4. Run the test suite. If your rule flips something, add a case that verifies
   `apply` → `revert` returns to the defaults.

Good first rule ideas belong in a
[Rule proposal](https://github.com/nekonaru/flip30/issues/new?template=rule_proposal.md)
issue first, so we can discuss tag conflicts before you invest time.

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add GRAVITASI SANTAI rule
fix: revert MUSUH JADI POIN escape penalty correctly
docs: clarify mod installation path on Linux
test: cover TIDAK BISA BERHENTI last_dir persistence
```

Types we use: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `perf`.

## Pull requests

- Keep PRs focused: one rule or one fix per PR.
- Fill in the PR template.
- CI must be green (tests + StyLua).
- If your change affects gameplay, attach a screenshot or a short clip
  (`love . --screenshot` helps).
- If your change alters behavior players see, add a `CHANGELOG.md` entry under
  `Unreleased`.

## Reporting bugs

Use the [bug report](https://github.com/nekonaru/flip30/issues/new?template=bug_report.md)
template. Include your platform, LÖVE version (`love --version`), and whether
any mods were loaded.
