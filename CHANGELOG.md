# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Extract common functions to `lib/common.sh`
- Extract graph meta parser to standalone `lib/parse_graph_meta.py`
- Refactor all scripts to use shared `lib/common.sh` functions
- Improve `gitnexus-doctor.sh` global version check (use `command -v` first)

### Added
- Unit tests in `tests/test_common.sh` for common functions
- Makefile with `install`, `test`, `clean`, `help` targets
- CHANGELOG.md
- Issue templates (bug report, feature request)
- CONTRIBUTING.md guide

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
