# Changelog

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
