# Contributing to gitnexus-stable-ops

Thank you for considering contributing! This project aims to provide reliable operational scripts for GitNexus stable environments.

## How to Contribute

### Reporting Bugs

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) to file issues.

Include:
- Your environment (OS, bash version, GitNexus version)
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs

### Suggesting Features

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md).

Please describe:
- The problem you're trying to solve
- Your proposed solution
- Alternatives you've considered

### Submitting Pull Requests

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create a branch** for your feature/fix
4. **Make changes** following our style guidelines
5. **Test** your changes (`make test`)
6. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `refactor:` for code restructuring
   - `test:` for test additions
7. **Push** to your fork
8. **Open a Pull Request** with a clear description

## Development Guidelines

### Code Style

- Use `set -euo pipefail` in all bash scripts
- Keep functions small and focused
- Add comments for non-obvious logic
- Use descriptive variable names

### Testing

- Add tests for new functions in `tests/test_common.sh`
- Run `make test` before committing
- Ensure scripts work on both macOS and Linux

### Documentation

- Update README.md for user-facing changes
- Update CHANGELOG.md following Keep a Changelog format
- Add inline comments for complex logic

## Project Structure

```
bin/           - Executable scripts
lib/           - Shared functions and utilities
tests/         - Unit tests
docs/          - Documentation
examples/      - Example configuration files
```

## Common Functions

When adding functionality that might be reused:
1. Add it to `lib/common.sh`
2. Document the function with usage examples
3. Add corresponding tests

## Compatibility

This project targets:
- **macOS** (Apple Silicon) - primary development platform
- **Linux** (Ubuntu, Debian, Fedora) - tested and supported
- **Windows** - not supported (use WSL)

## Questions?

Feel free to open a [discussion](https://github.com/ShunsukeHayashi/gitnexus-stable-ops/discussions) or reach out via issues.

We appreciate all contributions, big or small! 🙏
