# Changelog

## Unreleased

## 0.1.6 - 2026-09-10

### Fixed

- Forward per-NIF Zigler options, including dirty scheduler settings, when building from source with `force_build: true`.

## 0.1.5 - 2026-07-20

- Build native Windows artifacts in precompile mode so loaded DLLs do not block replacement.

## 0.1.4 - 2026-05-03

- Add `mix zigler_precompiled.build` for building a single target artifact without cross-targeting the whole dependency graph

## 0.1.3 - 2026-04-09

- Support per-NIF keyword options in `:nifs` list

## 0.1.2 - 2026-03-12

- Replace deprecated `Module.eval_quoted/2` with `Code.eval_quoted_with_env/3` for Elixir 1.18+ compatibility

## 0.1.1 - 2026-03-12

- Fix macro hygiene bug where `force_build` path passed an unbound variable to Zigler's `__using__` macro

## 0.1.0 - 2026-03-12

- Initial release
- `use ZiglerPrecompiled` macro for downloading and loading precompiled Zig NIFs
- Target detection for Linux, macOS, Windows, FreeBSD with Nerves support
- SHA-256 checksum verification
- Download caching with configurable retries and proxy support
- `mix zigler_precompiled.download` task for generating checksum files
- Force-build fallback to Zigler
- NixOS / offline support via `ZIGLER_PRECOMPILED_GLOBAL_CACHE_PATH`
