# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-03-19

### Added
- Git hooks for automatic reindex on commit/merge (`hooks/post-commit`, `hooks/post-merge`)
- `bin/gitnexus-install-hooks.sh` — hook installer with backup support
- `make install-hooks REPO=<path>` — Makefile target for hook installation
- `tests/test_hooks.sh` — 11 unit tests for hook functionality
- GitHub Actions CI workflow (macOS + Ubuntu matrix)
- Japanese README (`README_ja.md`)
- CI status badge in README.md
- Environment variables: `GITNEXUS_AUTO_REINDEX`, `GITNEXUS_STABLE_OPS`

### Changed
- Extract common functions to `lib/common.sh`
- Extract graph meta parser to standalone `lib/parse_graph_meta.py`
- Refactor all scripts to use shared `lib/common.sh` functions
- Improve `gitnexus-doctor.sh` global version check (use `command -v` first)
- Makefile `test` target now runs both `test_common.sh` and `test_hooks.sh`
- Updated `docs/runbook.md` with Git Hooks section
- Updated `README.md` with Git Hooks section and Features table

### Previously Added (pre-release)
- Unit tests in `tests/test_common.sh` for common functions
- Makefile with `install`, `test`, `clean`, `help` targets
- CHANGELOG.md
- Issue templates (bug report, feature request)
- CONTRIBUTING.md guide
- Chinese README (`README_zh.md`)

## [1.1.0] - 2026-03-18

### Fixed
- Skip empty repos (no commits) in reindex to avoid `exit 128` under `pipefail`
- macOS compatibility: `fuser → lsof` fallback in `gni` wrapper

### Changed
- Improved error handling for empty repositories

## [1.0.0] - 2026-03-18

### Added
- Initial release with 8 operational scripts:
  - `gitnexus-reindex.sh` - Incremental reindex of changed repos
  - `gitnexus-reindex-all.sh` - Full reindex from registry
  - `gitnexus-auto-reindex.sh` - Smart auto-reindexing with state tracking
  - `gitnexus-doctor.sh` - Health check and diagnostics
  - `gitnexus-safe-impact.sh` - Analyze code change impact
  - `gitnexus-smoke-test.sh` - Quick smoke tests
  - `graph-meta-update.sh` - Update graph metadata JSONL
  - `gni` - CLI wrapper for common operations
- Documentation: README.md, docs/
- Examples: `env.example`
- MIT License
