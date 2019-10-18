defmodule JsonSchemaTestSuite.Draft6.BooleanSchemaTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "boolean schema 'true'" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            true,
            draft: "draft6"
          )
      }
    end

    test "number is valid", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "string is valid", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "boolean true is valid", %{schema: schema} do
      assert valid?(schema, true)
    end

    test "boolean false is valid", %{schema: schema} do
      assert valid?(schema, false)
    end

    test "null is valid", %{schema: schema} do
      assert valid?(schema, nil)
    end

    test "object is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => "bar"})
    end

    test "empty object is valid", %{schema: schema} do
      assert valid?(schema, %{})
    end

    test "array is valid", %{schema: schema} do
      assert valid?(schema, ["foo"])
    end

    test "empty array is valid", %{schema: schema} do
      assert valid?(schema, [])
    end
  end

  describe "boolean schema 'false'" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            false,
            draft: "draft6"
          )
      }
    end

    test "number is invalid", %{schema: schema} do
      refute valid?(schema, 1)
    end

    test "string is invalid", %{schema: schema} do
      refute valid?(schema, "foo")
    end

    test "boolean true is invalid", %{schema: schema} do
      refute valid?(schema, true)
    end

    test "boolean false is invalid", %{schema: schema} do
      refute valid?(schema, false)
    end

    test "null is invalid", %{schema: schema} do
      refute valid?(schema, nil)
    end

    test "object is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar"})
    end

    test "empty object is invalid", %{schema: schema} do
      refute valid?(schema, %{})
    end

    test "array is invalid", %{schema: schema} do
      refute valid?(schema, ["foo"])
    end

    test "empty array is invalid", %{schema: schema} do
      refute valid?(schema, [])
    end
  end
end
