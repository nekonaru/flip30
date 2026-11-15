# Security Policy

Flip30 is a fully offline, single-player arcade game written in Lua for LÖVE. It has no backend, no accounts, no telemetry, and makes no network requests. The only data it stores is your high score, in one small local file.

## Reporting a vulnerability

This repository has GitHub Private Vulnerability Reporting enabled. To report a security issue privately, open the repository's Security tab and choose "Report a vulnerability". If that is not available to you, open a regular issue with no sensitive details and we will move the discussion to a private channel.

Please include: what you did, what happened, and what you expected. A minimal reproduction (a game save file, a mod file, or a screenshot) helps enormously.

## Scope

- The game itself (`src/`, `rules/`, `main.lua`, `conf.lua`).
- The build script (`scripts/build.ps1`, `scripts/build.sh`) and the release artifacts.
- The mod sandbox (`src/modloader.lua`). Mods are the only third-party code the game loads; they run in a restricted environment with no `os`, `io`, `package`, or `love` access.

## Out of scope

- Issues requiring physical access to an unlocked machine where the attacker can already modify the game files.
- Vulnerabilities in LÖVE, LuaJIT, or the operating system; report those upstream.
- Crashes caused by intentionally malformed third-party mods (mods run sandboxed; a broken mod prints an error and is skipped).

## Response

We aim to acknowledge a report within 7 days and to ship a fix or mitigation before the next release.

## Player safety

Flip30 collects no personal data, runs no network code, and ships no analytics. High score is the only persisted state and stays on your machine.
