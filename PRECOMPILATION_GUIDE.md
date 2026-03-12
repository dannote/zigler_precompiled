# Precompilation guide

This guide walks through setting up precompiled Zig NIFs for your Elixir library.

## Why precompile?

Zigler provides easy Zig NIFs, but every user needs the Zig compiler installed.
Precompilation removes that requirement — users download a pre-built shared
library that matches their platform.

## Advantages over Rust precompilation

Zig's cross-compilation story is dramatically simpler than Rust's:

- **No `cross` tool or Docker** — Zig can cross-compile to any target from any host
- **Single CI job** — a matrix of `-Dtarget=` flags builds everything
- **No NIF version matrix** — Zig compiles directly against `erl_nif.h`, so there's
  no separate NIF 2.15/2.16/2.17 dimension

## Configure GitHub Actions

Enable read/write permissions for the repository:

1. Settings → Actions → General
2. Workflow permissions → Read and write permissions

### Build workflow

```yaml
name: Build precompiled NIFs

on:
  push:
    tags: ['v*']

permissions:
  contents: write

jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        include:
          - { target: aarch64-linux-gnu,      os: ubuntu-latest }
          - { target: aarch64-linux-musl,     os: ubuntu-latest }
          - { target: aarch64-macos-none,     os: macos-latest }
          - { target: arm-linux-gnueabihf,    os: ubuntu-latest }
          - { target: arm-linux-musleabihf,   os: ubuntu-latest }
          - { target: riscv64-linux-gnu,      os: ubuntu-latest }
          - { target: x86_64-linux-gnu,       os: ubuntu-latest }
          - { target: x86_64-linux-musl,      os: ubuntu-latest }
          - { target: x86_64-macos-none,      os: macos-latest }
          - { target: x86_64-windows-gnu,     os: ubuntu-latest }
          - { target: x86-linux-gnu,          os: ubuntu-latest }
          - { target: x86-windows-gnu,        os: ubuntu-latest }

    steps:
      - uses: actions/checkout@v4

      - name: Install Zig
        uses: goto-bus-stop/setup-zig@v2
        with:
          version: 0.15.1

      - name: Install Erlang/Elixir
        uses: erlef/setup-beam@v1
        with:
          otp-version: '27'
          elixir-version: '1.17'

      - name: Build NIF
        run: |
          mix deps.get
          mix zig.get

          # Build for the target
          ZIGLER_PRECOMPILING=${{ matrix.target }} mix compile

      - name: Package artifact
        run: |
          VERSION=${GITHUB_REF#refs/tags/v}
          BASENAME="MyApp.Native"
          LIB_NAME="${BASENAME}-v${VERSION}-${{ matrix.target }}"

          # Find the built library
          if [[ "${{ matrix.target }}" == *windows* ]]; then
            EXT=".dll"
          else
            EXT=".so"
          fi

          mkdir -p artifacts
          cp priv/lib/*${EXT} "artifacts/"
          cd artifacts
          tar czf "${LIB_NAME}${EXT}.tar.gz" *${EXT}

      - name: Upload to release
        uses: softprops/action-gh-release@v1
        with:
          files: artifacts/*.tar.gz
```

> **Note:** The exact build script depends on your project structure. The key
> point is that Zig handles all cross-compilation natively — no Docker or `cross`
> needed.

## The NIF module

```elixir
defmodule MyApp.Native do
  version = Mix.Project.config()[:version]

  use ZiglerPrecompiled,
    otp_app: :my_app,
    base_url: "https://github.com/me/my_project/releases/download/v#{version}",
    version: version,
    force_build: System.get_env("MY_APP_BUILD") in ["1", "true"],
    nifs: [
      add: 2,
      multiply: 2
    ]
end
```

The `:nifs` option is required. It declares every NIF function as a
`{name, arity}` pair. ZiglerPrecompiled generates stub functions matching
Zigler's `marshalled-<name>` convention — these stubs are replaced when the
precompiled `.so` loads.

When `force_build: true`, the `:nifs` option is stripped and the remaining
options are passed to `use Zig`, which uses the Zig compiler for full
compilation with rich error tracing and type marshalling wrappers.

### Real-world example: QuickBEAM

```elixir
defmodule QuickBEAM.Native do
  version = Mix.Project.config()[:version]

  use ZiglerPrecompiled,
    otp_app: :quickbeam,
    base_url: "https://github.com/dannote/quickbeam/releases/download/v#{version}",
    version: version,
    nifs: [
      eval: 3, compile: 2, call_function: 4,
      load_module: 3, load_bytecode: 2,
      reset_runtime: 1, stop_runtime: 1, start_runtime: 2,
      resolve_call: 3, reject_call: 3,
      resolve_call_term: 3, reject_call_term: 3,
      send_message: 2, define_global: 3,
      memory_usage: 1,
      dom_find: 2, dom_find_all: 2, dom_text: 2,
      dom_attr: 3, dom_html: 1
    ]
end
```

## Generating checksums

After CI uploads all artifacts:

```bash
mix zigler_precompiled.download MyApp.Native --all --print
```

This creates `checksum-Elixir.MyApp.Native.exs`. You **must** include it in your
Hex package:

```elixir
defp package do
  [
    files: [
      "lib",
      "native",
      "checksum-*.exs",
      "mix.exs"
    ]
  ]
end
```

## Release flow

1. Tag a new release
2. Push: `git push origin main --tags`
3. Wait for all CI builds to finish
4. Run `mix zigler_precompiled.download MyApp.Native --all`
5. Publish to Hex (ensure `checksum-*.exs` is in `files:`)

## Forcing a local build

Set the env var or config to skip precompiled downloads:

```bash
MY_APP_BUILD=1 mix compile
```

Or in config:

```elixir
config :zigler_precompiled, :force_build, my_app: true
```

This requires `{:zigler, ">= 0.0.0", optional: true}` in your deps.
