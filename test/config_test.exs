defmodule ZiglerPrecompiled.ConfigTest do
  use ExUnit.Case, async: true

  alias ZiglerPrecompiled.Config

  describe "new/1" do
    test "builds config with required options" do
      config =
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: "https://example.com/releases",
          version: "1.0.0",
          nifs: [add: 2, multiply: 2]
        )

      assert config.otp_app == :my_app
      assert config.module == MyApp.Native
      assert config.version == "1.0.0"
      assert config.force_build? == false
      assert config.max_retries == 3
      assert config.load_data == 0
      assert config.nifs == [add: 2, multiply: 2]
    end

    test "pre-release version forces build" do
      config =
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: "https://example.com/releases",
          version: "1.0.0-dev",
          nifs: [add: 2]
        )

      assert config.force_build? == true
    end

    test "explicit force_build" do
      config =
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: "https://example.com/releases",
          version: "1.0.0",
          force_build: true,
          nifs: [add: 2]
        )

      assert config.force_build? == true
    end

    test "custom targets" do
      config =
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: "https://example.com/releases",
          version: "1.0.0",
          targets: ~w(x86_64-linux-gnu aarch64-linux-gnu),
          nifs: [add: 2]
        )

      assert config.targets == ~w(x86_64-linux-gnu aarch64-linux-gnu)
    end

    test "base_url with headers" do
      config =
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: {"https://example.com/releases", [{"Authorization", "Bearer token"}]},
          version: "1.0.0",
          nifs: [add: 2]
        )

      assert {"https://example.com/releases", [{"Authorization", "Bearer token"}]} =
               config.base_url
    end

    test "raises on missing otp_app" do
      assert_raise KeyError, fn ->
        Config.new(
          module: MyApp.Native,
          base_url: "https://example.com",
          version: "1.0.0",
          nifs: [add: 2]
        )
      end
    end

    test "raises on missing base_url" do
      assert_raise KeyError, fn ->
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          version: "1.0.0",
          nifs: [add: 2]
        )
      end
    end

    test "raises on missing nifs" do
      assert_raise RuntimeError, ~r/nifs.*required/, fn ->
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: "https://example.com",
          version: "1.0.0"
        )
      end
    end

    test "raises on invalid nifs entry" do
      assert_raise RuntimeError, ~r/nifs.*entries/, fn ->
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: "https://example.com",
          version: "1.0.0",
          nifs: [{"bad", "entry"}]
        )
      end
    end

    test "raises on invalid max_retries" do
      assert_raise RuntimeError, ~r/max_retries/, fn ->
        Config.new(
          otp_app: :my_app,
          module: MyApp.Native,
          base_url: "https://example.com",
          version: "1.0.0",
          nifs: [add: 2],
          max_retries: 100
        )
      end
    end
  end

  describe "default_targets/0" do
    test "returns a list of zig-style triples" do
      targets = Config.default_targets()
      assert is_list(targets)
      assert length(targets) > 0

      for target <- targets do
        parts = String.split(target, "-")
        assert length(parts) == 3, "expected 3-part triple, got #{target}"
      end
    end

    test "includes common platforms" do
      targets = Config.default_targets()
      assert "x86_64-linux-gnu" in targets
      assert "aarch64-linux-gnu" in targets
      assert "aarch64-macos-none" in targets
      assert "x86_64-macos-none" in targets
      assert "x86_64-windows-gnu" in targets
    end
  end
end
