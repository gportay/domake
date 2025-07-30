# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [unreleased]

### Added

- Add --platform option and `DOSH_PLATFORM` environment to support
  [multi-platform].

## [2] - 2025-07-16

### Added

- Fix argument variables containing whitespaces.

### Changed

- Rename `DOCKER` to `DOSH_DOCKER`.
- Run `dosh --rm` and `DOSH_DOCKER` from dosh 4 on exit.

## [1] - 2020-02-04

Initial release.

[multi-platform]: https://docs.docker.com/build/building/multi-platform/
[unreleased]: https://github.com/gportay/domake/compare/2...master
[1]: https://github.com/gportay/domake/releases/tag/1
[2]: https://github.com/gportay/domake/releases/tag/2
