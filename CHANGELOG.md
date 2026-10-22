# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses
[Semantic Versioning](https://semver.org/).

## 1.0.2 - 2026-10-21

### Fixed

- The `:tolerance` config is now tracked by Mix. Before, it was read while *your* code compiled
  without Mix knowing, so changing it in `config.exs` could leave some modules using the old
  value until a forced recompile. Changing it now recompiles everything that uses the guards.
- The README example `is_eq_ish(0.1 + 0.2) == 0.3` did not compile. It is now
  `is_eq_ish(0.1 + 0.2, 0.3)`.
- The package's GitHub link pointed to the wrong repository.

### Changed

- **A release now fails to boot if `config/runtime.exs` sets a different `:tolerance` than
  the one it was compiled with.** Before, the runtime value was ignored without any warning.
  Guards cannot read config at runtime, so set the tolerance in `config/config.exs` instead.
  (`mix run` and `iex -S mix` still ignore the runtime value.)
- Typespecs now accept any number as the tolerance, not just floats. Integer tolerances
  already worked.

### Documentation

- Explained that the tolerance is a compile-time setting, and where to set it.
- Explained that the tolerance is a fixed amount, not a percentage, with examples of where
  that matters for very large and very small numbers.
- Added this changelog.

## 1.0.1 - 2026-09-03

- Version bump only.

## 1.0.0 - 2026-09-03

- Initial release: `is_eq_ish`, `is_not_eq_ish`, `is_gt_ish`, `is_gte_ish`, `is_lt_ish` and
  `is_lte_ish`, usable as guards or ordinary expressions, with an optional tolerance argument
  and a configurable default.
