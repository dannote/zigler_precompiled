# ZiglerPrecompiled

Download and use precompiled [Zigler](https://github.com/E-xyza/zigler) NIFs
safely with SHA-256 checksums.

Removes the need for end users to install the Zig compiler. Library maintainers
build NIFs in CI for each platform, upload them as release artifacts, and ship a
checksum file with the Hex package.

## Installation

```elixir
def deps do
  [
    {:zigler_precompiled, "~> 0.1.0"}
  ]
end
```

For library maintainers who also need to compile from source:

```elixir
def deps do
  [
    {:zigler_precompiled, "~> 0.1.0"},
    {:zigler, "~> 0.15", optional: true}
  ]
end
```

## Quick start

### Defining a precompiled NIF module

```elixir
defmodule MyApp.Native do
  version = Mix.Project.config()[:version]

  use ZiglerPrecompiled,
    otp_app: :my_app,
    base_url: "https://github.com/me/my_project/releases/download/v#{version}",
    version: version,
    nifs: [
      add: 2,
      multiply: 2
    ]
end
```

The `:nifs` option is **required** — it declares which NIF functions the module
exports as `{name, arity}` pairs. These generate stub functions that are
replaced when the precompiled `.so` loads.

When `force_build: true` (or a pre-release version like `"0.1.0-dev"`), the
`:nifs` option is ignored and compilation is delegated to `use Zig` with
Zigler's full wrapper generation.

### Building and releasing

1. Tag a release and push
2. CI builds the NIF for each target and uploads `.tar.gz` artifacts
3. Run `mix zigler_precompiled.download MyApp.Native --all --print`
4. Include `checksum-*.exs` in your Hex package files
5. Publish to Hex

See [PRECOMPILATION_GUIDE.md](PRECOMPILATION_GUIDE.md) for the full walkthrough.

## How it works

Zigler generates rich NIF wrapper functions (type marshalling, error tracing)
at compile time by analyzing Zig source. The compiled `.so` registers NIF
functions under `marshalled-<name>` names. ZiglerPrecompiled generates matching
stubs that delegate to these, so when `:erlang.load_nif` runs at `@on_load`,
the stubs are replaced with the real implementations.

This has been verified to work end-to-end with
[QuickBEAM](https://github.com/dannote/quickbeam) (20 NIFs including resources,
dirty schedulers, C interop with QuickJS and Lexbor).

## License

MIT
