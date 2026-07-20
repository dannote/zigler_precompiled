# Changelog

## v0.1.5

- Build native Windows artifacts in precompile mode so loaded DLLs do not block replacement.

## v0.1.4

- Add `mix zigler_precompiled.build` for building a single target artifact without cross-targeting the whole dependency graph

## v0.1.3

- Support per-NIF keyword options in `:nifs` list

## v0.1.2

- Replace deprecated `Module.eval_quoted/2` with `Code.eval_quoted_with_env/3` for Elixir 1.18+ compatibility

## v0.1.1

- Fix macro hygiene bug where `force_build` path passed an unbound variable to Zigler's `__using__` macro

## v0.1.0

- Initial release
- `use ZiglerPrecompiled` macro for downloading and loading precompiled Zig NIFs
- Target detection for Linux, macOS, Windows, FreeBSD with Nerves support
- SHA-256 checksum verification
- Download caching with configurable retries and proxy support
- `mix zigler_precompiled.download` task for generating checksum files
- Force-build fallback to Zigler
- NixOS / offline support via `ZIGLER_PRECOMPILED_GLOBAL_CACHE_PATH`
