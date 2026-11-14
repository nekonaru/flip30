## Summary

<!-- What does this change do and why? One or two sentences. -->

## Type of change

- [ ] `feat` — new gameplay, rule, or UI
- [ ] `fix` — bug fix
- [ ] `docs` — documentation only
- [ ] `test` — test suite only
- [ ] `refactor` / `chore` / `ci`

## Checklist

- [ ] `luajit tests/headless_tests.lua` passes
- [ ] `stylua .` produces no diff (CI checks `--check`)
- [ ] New rules restore ALL touched state in `revert()`
- [ ] New rules are listed in `tests/headless_tests.lua`
- [ ] Game manually smoke-tested: menu → play → game over → restart
- [ ] Screenshots attached for visible changes

## Notes for the reviewer

<!-- Anything that needs a second pair of eyes: rule balance, state reset order, UI copy. -->
