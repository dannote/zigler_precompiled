defmodule ZiglerPrecompiledTest do
  use ExUnit.Case, async: true

  describe "current_target_triple/0" do
    test "returns a valid triple for the current system" do
      triple = ZiglerPrecompiled.current_target_triple()
      parts = String.split(triple, "-")
      assert length(parts) == 3
    end

    test "arch is normalized" do
      assert String.split(ZiglerPrecompiled.current_target_triple(), "-")
             |> hd()
             |> then(&(&1 in ~w[x86_64 x86 aarch64 arm riscv64]))
    end
  end

  describe "target/1" do
    test "returns ok when target is in the list" do
      triple = ZiglerPrecompiled.current_target_triple()
      assert {:ok, ^triple} = ZiglerPrecompiled.target([triple])
    end

    test "returns error when target is not available" do
      assert {:error, msg} = ZiglerPrecompiled.target(["riscv128-plan9-none"])
      assert msg =~ "not available"
    end
  end

  describe "maybe_override_with_env_vars/2" do
    test "uses TARGET_ARCH when set" do
      sys = %{arch: "x86_64", vendor: "unknown", os: "linux", abi: "gnu"}

      result =
        ZiglerPrecompiled.maybe_override_with_env_vars(sys, fn
          "TARGET_ARCH" -> "aarch64"
          _ -> nil
        end)

      assert result.arch == "aarch64"
    end

    test "uses TARGET_OS when set" do
      sys = %{arch: "x86_64", vendor: "unknown", os: "linux", abi: "gnu"}

      result =
        ZiglerPrecompiled.maybe_override_with_env_vars(sys, fn
          "TARGET_OS" -> "freebsd"
          _ -> nil
        end)

      assert result.os == "freebsd"
    end

    test "leaves unchanged when no env vars" do
      sys = %{arch: "x86_64", vendor: "unknown", os: "linux", abi: "gnu"}

      result = ZiglerPrecompiled.maybe_override_with_env_vars(sys, fn _ -> nil end)
      assert result == sys
    end
  end

  describe "lib_name/3" do
    test "formats correctly" do
      assert ZiglerPrecompiled.lib_name("my_nif", "1.0.0", "x86_64-linux-gnu") ==
               "my_nif-v1.0.0-x86_64-linux-gnu"
    end
  end

  describe "lib_name_with_ext/2" do
    test "uses .so.tar.gz for linux" do
      assert ZiglerPrecompiled.lib_name_with_ext(
               "x86_64-linux-gnu",
               "my_nif-v1.0.0-x86_64-linux-gnu"
             ) ==
               "my_nif-v1.0.0-x86_64-linux-gnu.so.tar.gz"
    end

    test "uses .dll.tar.gz for windows" do
      assert ZiglerPrecompiled.lib_name_with_ext(
               "x86_64-windows-gnu",
               "my_nif-v1.0.0-x86_64-windows-gnu"
             ) ==
               "my_nif-v1.0.0-x86_64-windows-gnu.dll.tar.gz"
    end

    test "uses .so.tar.gz for macos" do
      assert ZiglerPrecompiled.lib_name_with_ext(
               "aarch64-macos-none",
               "my_nif-v1.0.0-aarch64-macos-none"
             ) ==
               "my_nif-v1.0.0-aarch64-macos-none.so.tar.gz"
    end
  end

  describe "tar_gz_file_url/2" do
    test "with string base_url" do
      assert {"https://example.com/releases/my_nif.so.tar.gz", []} =
               ZiglerPrecompiled.tar_gz_file_url(
                 "https://example.com/releases",
                 "my_nif.so.tar.gz"
               )
    end

    test "with {url, headers} base_url" do
      assert {"https://example.com/releases/my_nif.so.tar.gz", [{"Authorization", "Bearer x"}]} =
               ZiglerPrecompiled.tar_gz_file_url(
                 {"https://example.com/releases", [{"Authorization", "Bearer x"}]},
                 "my_nif.so.tar.gz"
               )
    end
  end
end
