defmodule Draft7.TupleItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "a schema given for items" do
    setup do
      %{schema: Xema.new(:items, :integer)}
    end

    test "valid items", %{schema: schema} do
      data = {1, 2, 3}
      assert valid?(schema, data)
    end

    test "wrong type of items", %{schema: schema} do
      data = {1, "x"}
      refute valid?(schema, data)
    end

    test "ignores non-tuples", %{schema: schema} do
      data = %{foo: "bar"}
      assert valid?(schema, data)
    end
  end

  describe "an tuple of schemas for items" do
    setup do
      %{schema: Xema.new(:items, [:integer, :string])}
    end

    test "correct types", %{schema: schema} do
      data = {1, "foo"}
      assert valid?(schema, data)
    end

    test "wrong types", %{schema: schema} do
      data = {"foo", 1}
      refute valid?(schema, data)
    end

    test "incomplete tuple of items", %{schema: schema} do
      data = {1}
      assert valid?(schema, data)
    end

    test "tuple with additional items", %{schema: schema} do
      data = {1, "foo", true}
      assert valid?(schema, data)
    end

    test "empty tuple", %{schema: schema} do
      data = {}
      assert valid?(schema, data)
    end
  end

  describe "items with boolean schema (true)" do
    setup do
      %{schema: Xema.new(:items, true)}
    end

    test "any tuple is valid", %{schema: schema} do
      data = {1, "foo", true}
      assert valid?(schema, data)
    end

    test "empty tuple is valid", %{schema: schema} do
      data = {}
      assert valid?(schema, data)
    end
  end

  describe "items with boolean schema (false)" do
    setup do
      %{schema: Xema.new(:items, false)}
    end

    test "any non-empty tuple is invalid", %{schema: schema} do
      data = {1, "foo", true}
      refute valid?(schema, data)
    end

    test "empty tuple is valid", %{schema: schema} do
      data = {}
      assert valid?(schema, data)
    end
  end

  describe "items with boolean schemas" do
    setup do
      %{schema: Xema.new(:items, [true, false])}
    end

    test "tuple with one item is valid", %{schema: schema} do
      data = {1}
      assert valid?(schema, data)
    end

    test "tuple with two items is invalid", %{schema: schema} do
      data = {1, "foo"}
      refute valid?(schema, data)
    end

    test "empty tuple is valid", %{schema: schema} do
      data = {}
      assert valid?(schema, data)
    end
  end
end
