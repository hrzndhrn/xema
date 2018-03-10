defmodule Draft4.MinItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "minItems validation" do
    setup do
      %{schema: Xema.new(:min_items, 1)}
    end

    @tag :draft4
    @tag :min_items
    test "longer is valid", %{schema: schema} do
      data = [1, 2]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :min_items
    test "exact length is valid", %{schema: schema} do
      data = [1]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :min_items
    test "too short is invalid", %{schema: schema} do
      data = []
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :min_items
    test "ignores non-arrays", %{schema: schema} do
      data = ""
      assert is_valid?(schema, data)
    end
  end
end
