defmodule Draft6.UniqueItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "uniqueItems validation" do
    setup do
      %{schema: Xema.new(:unique_items, true)}
    end

    test "unique array of integers is valid", %{schema: schema} do
      data = [1, 2]
      assert valid?(schema, data)
    end

    test "non-unique array of integers is invalid", %{schema: schema} do
      data = [1, 1]
      refute valid?(schema, data)
    end

    test "numbers are unique if mathematically unequal", %{schema: schema} do
      data = [1.0, 1.0, 1]
      refute valid?(schema, data)
    end

    test "unique array of objects is valid", %{schema: schema} do
      data = [%{foo: "bar"}, %{foo: "baz"}]
      assert valid?(schema, data)
    end

    test "non-unique array of objects is invalid", %{schema: schema} do
      data = [%{foo: "bar"}, %{foo: "bar"}]
      refute valid?(schema, data)
    end

    test "unique array of nested objects is valid", %{schema: schema} do
      data = [%{foo: %{bar: %{baz: true}}}, %{foo: %{bar: %{baz: false}}}]
      assert valid?(schema, data)
    end

    test "non-unique array of nested objects is invalid", %{schema: schema} do
      data = [%{foo: %{bar: %{baz: true}}}, %{foo: %{bar: %{baz: true}}}]
      refute valid?(schema, data)
    end

    test "unique array of arrays is valid", %{schema: schema} do
      data = [["foo"], ["bar"]]
      assert valid?(schema, data)
    end

    test "non-unique array of arrays is invalid", %{schema: schema} do
      data = [["foo"], ["foo"]]
      refute valid?(schema, data)
    end

    test "1 and true are unique", %{schema: schema} do
      data = [1, true]
      assert valid?(schema, data)
    end

    test "0 and false are unique", %{schema: schema} do
      data = [0, false]
      assert valid?(schema, data)
    end

    test "unique heterogeneous types are valid", %{schema: schema} do
      data = [%{}, [1], true, nil, 1]
      assert valid?(schema, data)
    end

    test "non-unique heterogeneous types are invalid", %{schema: schema} do
      data = [%{}, [1], true, nil, %{}, 1]
      refute valid?(schema, data)
    end
  end
end
