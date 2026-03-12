defmodule ZiglerPrecompiled.MacroTest do
  use ExUnit.Case, async: true

  describe "generate_nif_stubs/1" do
    test "raises on nil" do
      assert_raise ArgumentError, ~r/nifs/, fn ->
        ZiglerPrecompiled.generate_nif_stubs(nil)
      end
    end

    test "generates quoted code for each nif" do
      stubs = ZiglerPrecompiled.generate_nif_stubs(add: 2, zero: 0)
      assert is_list(stubs)
      assert length(stubs) == 2
    end

    test "generated stubs define marshalled and public functions" do
      [{:__block__, _, defs} | _] = ZiglerPrecompiled.generate_nif_stubs(foo: 1)

      fun_names =
        for {:def, _, [{name, _, _} | _]} <- defs, do: name

      assert :"marshalled-foo" in fun_names
      assert :foo in fun_names
    end
  end
end
