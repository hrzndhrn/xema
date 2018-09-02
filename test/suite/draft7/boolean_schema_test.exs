defmodule Draft7.BooleanSchemaTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "boolean schema 'true'" do
    setup do
      %{schema: Xema.new(true)}
    end

    test "number is valid", %{schema: schema} do
      data = 1
      assert is_valid?(schema, data)
    end

    test "string is valid", %{schema: schema} do
      data = "foo"
      assert is_valid?(schema, data)
    end

    test "boolean true is valid", %{schema: schema} do
      data = true
      assert is_valid?(schema, data)
    end

    test "boolean false is valid", %{schema: schema} do
      data = false
      assert is_valid?(schema, data)
    end

    test "null is valid", %{schema: schema} do
      data = nil
      assert is_valid?(schema, data)
    end

    test "object is valid", %{schema: schema} do
      data = %{foo: "bar"}
      assert is_valid?(schema, data)
    end

    test "empty object is valid", %{schema: schema} do
      data = %{}
      assert is_valid?(schema, data)
    end

    test "array is valid", %{schema: schema} do
      data = ["foo"]
      assert is_valid?(schema, data)
    end

    test "empty array is valid", %{schema: schema} do
      data = []
      assert is_valid?(schema, data)
    end
  end

  describe "boolean schema 'false'" do
    setup do
      %{schema: Xema.new(false)}
    end

    test "number is invalid", %{schema: schema} do
      data = 1
      refute is_valid?(schema, data)
    end

    test "string is invalid", %{schema: schema} do
      data = "foo"
      refute is_valid?(schema, data)
    end

    test "boolean true is invalid", %{schema: schema} do
      data = true
      refute is_valid?(schema, data)
    end

    test "boolean false is invalid", %{schema: schema} do
      data = false
      refute is_valid?(schema, data)
    end

    test "null is invalid", %{schema: schema} do
      data = nil
      refute is_valid?(schema, data)
    end

    test "object is invalid", %{schema: schema} do
      data = %{foo: "bar"}
      refute is_valid?(schema, data)
    end

    test "empty object is invalid", %{schema: schema} do
      data = %{}
      refute is_valid?(schema, data)
    end

    test "array is invalid", %{schema: schema} do
      data = ["foo"]
      refute is_valid?(schema, data)
    end

    test "empty array is invalid", %{schema: schema} do
      data = []
      refute is_valid?(schema, data)
    end
  end
end
