defmodule Draft7.MinItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "minItems validation" do
    setup do
      %{schema: Xema.new(:min_items, 1)}
    end

    test "longer is valid", %{schema: schema} do
      data = [1, 2]
      assert valid?(schema, data)
    end

    test "exact length is valid", %{schema: schema} do
      data = [1]
      assert valid?(schema, data)
    end

    test "too short is invalid", %{schema: schema} do
      data = []
      refute valid?(schema, data)
    end

    test "ignores non-arrays", %{schema: schema} do
      data = ""
      assert valid?(schema, data)
    end
  end
end
