defmodule Draft6.BooleanSchemaTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "boolean schema 'true'" do
    setup do
      %{schema: Xema.new(true)}
    end

    test "number is valid", %{schema: schema} do
      data = 1
      assert valid?(schema, data)
    end

    test "string is valid", %{schema: schema} do
      data = "foo"
      assert valid?(schema, data)
    end

    test "boolean true is valid", %{schema: schema} do
      data = true
      assert valid?(schema, data)
    end

    test "boolean false is valid", %{schema: schema} do
      data = false
      assert valid?(schema, data)
    end

    test "null is valid", %{schema: schema} do
      data = nil
      assert valid?(schema, data)
    end

    test "object is valid", %{schema: schema} do
      data = %{foo: "bar"}
      assert valid?(schema, data)
    end

    test "empty object is valid", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end

    test "array is valid", %{schema: schema} do
      data = ["foo"]
      assert valid?(schema, data)
    end

    test "empty array is valid", %{schema: schema} do
      data = []
      assert valid?(schema, data)
    end
  end

  describe "boolean schema 'false'" do
    setup do
      %{schema: Xema.new(false)}
    end

    test "number is invalid", %{schema: schema} do
      data = 1
      refute valid?(schema, data)
    end

    test "string is invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end

    test "boolean true is invalid", %{schema: schema} do
      data = true
      refute valid?(schema, data)
    end

    test "boolean false is invalid", %{schema: schema} do
      data = false
      refute valid?(schema, data)
    end

    test "null is invalid", %{schema: schema} do
      data = nil
      refute valid?(schema, data)
    end

    test "object is invalid", %{schema: schema} do
      data = %{foo: "bar"}
      refute valid?(schema, data)
    end

    test "empty object is invalid", %{schema: schema} do
      data = %{}
      refute valid?(schema, data)
    end

    test "array is invalid", %{schema: schema} do
      data = ["foo"]
      refute valid?(schema, data)
    end

    test "empty array is invalid", %{schema: schema} do
      data = []
      refute valid?(schema, data)
    end
  end
end
