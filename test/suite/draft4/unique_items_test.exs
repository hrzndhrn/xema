defmodule Suite.Draft4.UniqueItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "unique_items validation" do
    setup do
      %{schema: Xema.new(:unique_items, true)}
    end

    @tag :draft4
    @tag :unique_items
    test "unique array of integers is valid", %{schema: schema} do
      data = [1, 2]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "non-unique array of integers is invalid", %{schema: schema} do
      data = [1, 1]
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "numbers are unique if mathematically unequal", %{schema: schema} do
      data = [1.0, 1.0, 1]
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "unique array of objects is valid", %{schema: schema} do
      data = [%{foo: "bar"}, %{foo: "baz"}]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "non-unique array of objects is invalid", %{schema: schema} do
      data = [%{foo: "bar"}, %{foo: "bar"}]
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "unique array of nested objects is valid", %{schema: schema} do
      data = [%{foo: %{bar: %{baz: true}}}, %{foo: %{bar: %{baz: false}}}]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "non-unique array of nested objects is invalid", %{schema: schema} do
      data = [%{foo: %{bar: %{baz: true}}}, %{foo: %{bar: %{baz: true}}}]
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "unique array of arrays is valid", %{schema: schema} do
      data = [["foo"], ["bar"]]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "non-unique array of arrays is invalid", %{schema: schema} do
      data = [["foo"], ["foo"]]
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "1 and true are unique", %{schema: schema} do
      data = [1, true]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "0 and false are unique", %{schema: schema} do
      data = [0, false]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "unique heterogeneous types are valid", %{schema: schema} do
      data = [%{}, [1], true, nil, 1]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :unique_items
    test "non-unique heterogeneous types are invalid", %{schema: schema} do
      data = [%{}, [1], true, nil, %{}, 1]
      refute is_valid?(schema, data)
    end
  end
end
