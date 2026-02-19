# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial VneTemplate project: CMake configuration, build scripts (Linux, macOS, Windows), clang-format and clang-tidy setup.
- Project structure: `include/`, `src/`, `tests/`, `examples/`, `deps/`, `scripts/`, `docs/`.
- Library API: `vne::template_ns::get_version()`, `vne::template_ns::hello()`.
- Example: `01_hello_template` with logging guard.
- CI: Ubuntu, macOS, Windows; clang-format check; clang-tidy; tests; coverage (Codecov).
- Options: `VNE_TEMPLATE_TESTS`, `VNE_TEMPLATE_EXAMPLES`, `VNE_TEMPLATE_DEV`, `VNE_TEMPLATE_CI`.

### Changed

- (None yet.)

### Deprecated

- (None.)

### Removed

- (None.)

### Fixed

- (None.)

### Security

- (None.)

---

## [1.0.0] - 2026-02-18

- Initial release.
