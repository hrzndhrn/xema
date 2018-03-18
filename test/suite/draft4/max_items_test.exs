defmodule Draft4.MaxItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "maxItems validation" do
    setup do
      %{schema: Xema.new(:max_items, 2)}
    end

    test "shorter is valid", %{schema: schema} do
      data = [1]
      assert is_valid?(schema, data)
    end

    test "exact length is valid", %{schema: schema} do
      data = [1, 2]
      assert is_valid?(schema, data)
    end

    test "too long is invalid", %{schema: schema} do
      data = [1, 2, 3]
      refute is_valid?(schema, data)
    end

    test "ignores non-arrays", %{schema: schema} do
      data = "foobar"
      assert is_valid?(schema, data)
    end
  end
end
