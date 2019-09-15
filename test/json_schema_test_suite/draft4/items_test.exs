defmodule JsonSchemaTestSuite.Draft4.Items do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "a schema given for items" do
    setup do
      %{schema: Xema.from_json_schema(%{"items" => %{"type" => "integer"}})}
    end

    test "valid items", %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test "wrong type of items", %{schema: schema} do
      refute valid?(schema, [1, "x"])
    end

    test "ignores non-arrays", %{schema: schema} do
      assert valid?(schema, %{"foo" => "bar"})
    end

    test "JavaScript pseudo-array is valid", %{schema: schema} do
      assert valid?(schema, %{"0" => "invalid", "length" => 1})
    end
  end

  describe "an array of schemas for items" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{"items" => [%{"type" => "integer"}, %{"type" => "string"}]})
      }
    end

    test "correct types", %{schema: schema} do
      assert valid?(schema, [1, "foo"])
    end

    test "wrong types", %{schema: schema} do
      refute valid?(schema, ["foo", 1])
    end

    test "incomplete array of items", %{schema: schema} do
      assert valid?(schema, [1])
    end

    test "array with additional items", %{schema: schema} do
      assert valid?(schema, [1, "foo", true])
    end

    test "empty array", %{schema: schema} do
      assert valid?(schema, [])
    end

    test "JavaScript pseudo-array is valid", %{schema: schema} do
      assert valid?(schema, %{"0" => "invalid", "1" => "valid", "length" => 2})
    end
  end

  describe "items and subitems" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "additionalItems" => false,
            "definitions" => %{
              "item" => %{
                "additionalItems" => false,
                "items" => [
                  %{"$ref" => "#/definitions/sub-item"},
                  %{"$ref" => "#/definitions/sub-item"}
                ],
                "type" => "array"
              },
              "sub-item" => %{"required" => ["foo"], "type" => "object"}
            },
            "items" => [
              %{"$ref" => "#/definitions/item"},
              %{"$ref" => "#/definitions/item"},
              %{"$ref" => "#/definitions/item"}
            ],
            "type" => "array"
          })
      }
    end

    test "valid items", %{schema: schema} do
      assert valid?(schema, [
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test "too many items", %{schema: schema} do
      refute valid?(schema, [
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test "too many sub-items", %{schema: schema} do
      refute valid?(schema, [
               [%{"foo" => nil}, %{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test "wrong item", %{schema: schema} do
      refute valid?(schema, [
               %{"foo" => nil},
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test "wrong sub-item", %{schema: schema} do
      refute valid?(schema, [
               [%{}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test "fewer items is valid", %{schema: schema} do
      assert valid?(schema, [[%{"foo" => nil}], [%{"foo" => nil}]])
    end
  end

  describe "nested items" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "items" => %{
              "items" => %{
                "items" => %{"items" => %{"type" => "number"}, "type" => "array"},
                "type" => "array"
              },
              "type" => "array"
            },
            "type" => "array"
          })
      }
    end

    test "valid nested array", %{schema: schema} do
      assert valid?(schema, [[[[1]], [[2], [3]]], [[[4], [5], [6]]]])
    end

    test "nested array with invalid type", %{schema: schema} do
      refute valid?(schema, [[[["1"]], [[2], [3]]], [[[4], [5], [6]]]])
    end

    test "not deep enough", %{schema: schema} do
      refute valid?(schema, [[[1], [2], [3]], [[4], [5], [6]]])
    end
  end
end
