defmodule Draft6.ConstTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "const validation" do
    setup do
      %{schema: Xema.new(:const, 2)}
    end

    test "same value is valid", %{schema: schema} do
      data = 2
      assert is_valid?(schema, data)
    end

    test "another value is invalid", %{schema: schema} do
      data = 5
      refute is_valid?(schema, data)
    end

    test "another type is invalid", %{schema: schema} do
      data = "a"
      refute is_valid?(schema, data)
    end
  end

  describe "const with object" do
    setup do
      %{schema: Xema.new(:const, %{baz: "bax", foo: "bar"})}
    end

    test "same object is valid", %{schema: schema} do
      data = %{baz: "bax", foo: "bar"}
      assert is_valid?(schema, data)
    end

    test "same object with different property order is valid", %{schema: schema} do
      data = %{baz: "bax", foo: "bar"}
      assert is_valid?(schema, data)
    end

    test "another object is invalid", %{schema: schema} do
      data = %{foo: "bar"}
      refute is_valid?(schema, data)
    end

    test "another type is invalid", %{schema: schema} do
      data = [1, 2]
      refute is_valid?(schema, data)
    end
  end

  describe "const with array" do
    setup do
      %{schema: Xema.new(:const, [%{foo: "bar"}])}
    end

    test "same array is valid", %{schema: schema} do
      data = [%{foo: "bar"}]
      assert is_valid?(schema, data)
    end

    test "another array item is invalid", %{schema: schema} do
      data = [2]
      refute is_valid?(schema, data)
    end

    test "array with additional items is invalid", %{schema: schema} do
      data = [1, 2, 3]
      refute is_valid?(schema, data)
    end
  end

  describe "const with null" do
    setup do
      %{schema: Xema.new(:const, nil)}
    end

    test "null is valid", %{schema: schema} do
      data = nil
      assert is_valid?(schema, data)
    end

    test "not null is invalid", %{schema: schema} do
      data = 0
      refute is_valid?(schema, data)
    end
  end
end
