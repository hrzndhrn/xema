defmodule Draft6.ContainsTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "contains keyword validation" do
    setup do
      %{schema: Xema.new(contains: [minimum: 5])}
    end

    test "array with item matching schema (5) is valid", %{schema: schema} do
      data = [3, 4, 5]
      assert valid?(schema, data)
    end

    test "array with item matching schema (6) is valid", %{schema: schema} do
      data = [3, 4, 6]
      assert valid?(schema, data)
    end

    test "array with two items matching schema (5, 6) is valid", %{
      schema: schema
    } do
      data = [3, 4, 5, 6]
      assert valid?(schema, data)
    end

    test "array without items matching schema is invalid", %{schema: schema} do
      data = [2, 3, 4]
      refute valid?(schema, data)
    end

    test "empty array is invalid", %{schema: schema} do
      data = []
      refute valid?(schema, data)
    end

    test "not array is valid", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end
  end

  describe "contains keyword with const keyword" do
    setup do
      %{schema: Xema.new(contains: [const: 5])}
    end

    test "array with item 5 is valid", %{schema: schema} do
      data = [3, 4, 5]
      assert valid?(schema, data)
    end

    test "array with two items 5 is valid", %{schema: schema} do
      data = [3, 4, 5, 5]
      assert valid?(schema, data)
    end

    test "array without item 5 is invalid", %{schema: schema} do
      data = [1, 2, 3, 4]
      refute valid?(schema, data)
    end
  end

  describe "contains keyword with boolean schema true" do
    setup do
      %{schema: Xema.new(contains: true)}
    end

    test "any non-empty array is valid", %{schema: schema} do
      data = ["foo"]
      assert valid?(schema, data)
    end

    test "empty array is invalid", %{schema: schema} do
      data = []
      refute valid?(schema, data)
    end
  end

  describe "contains keyword with boolean schema false" do
    setup do
      %{schema: Xema.new(contains: false)}
    end

    test "any non-empty array is invalid", %{schema: schema} do
      data = ["foo"]
      refute valid?(schema, data)
    end

    test "empty array is invalid", %{schema: schema} do
      data = []
      refute valid?(schema, data)
    end
  end
end
