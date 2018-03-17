defmodule Draft4.ItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "a schema given for items" do
    setup do
      %{schema: Xema.new(:items, :integer)}
    end

    test "valid items", %{schema: schema} do
      data = [1, 2, 3]
      assert is_valid?(schema, data)
    end

    test "wrong type of items", %{schema: schema} do
      data = [1, "x"]
      refute is_valid?(schema, data)
    end

    test "ignores non-arrays", %{schema: schema} do
      data = %{foo: "bar"}
      assert is_valid?(schema, data)
    end

    test "JavaScript pseudo-array is valid", %{schema: schema} do
      data = %{"0": "invalid", length: 1}
      assert is_valid?(schema, data)
    end
  end

  describe "an array of schemas for items" do
    setup do
      %{schema: Xema.new(:items, [:integer, :string])}
    end

    test "correct types", %{schema: schema} do
      data = [1, "foo"]
      assert is_valid?(schema, data)
    end

    test "wrong types", %{schema: schema} do
      data = ["foo", 1]
      refute is_valid?(schema, data)
    end

    test "incomplete array of items", %{schema: schema} do
      data = [1]
      assert is_valid?(schema, data)
    end

    test "array with additional items", %{schema: schema} do
      data = [1, "foo", true]
      assert is_valid?(schema, data)
    end

    test "empty array", %{schema: schema} do
      data = []
      assert is_valid?(schema, data)
    end

    test "JavaScript pseudo-array is valid", %{schema: schema} do
      data = %{"0": "invalid", "1": "valid", length: 2}
      assert is_valid?(schema, data)
    end
  end
end
