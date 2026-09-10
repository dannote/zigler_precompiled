defmodule ZiglerPrecompiled.ForceBuildTest do
  use ExUnit.Case, async: true

  defmodule TypedDirtyNif do
    use ZiglerPrecompiled,
      otp_app: :zigler_precompiled,
      base_url: "https://example.com/releases",
      version: "0.0.0",
      force_build: true,
      zig_code_path: "./test/fixtures/typed_dirty.zig",
      nifs: [typed_dirty: [arity: 1, concurrency: :dirty_cpu]]
  end

  test "force-builds a typed dirty NIF" do
    assert TypedDirtyNif.typed_dirty(42) == 42
  end
end
