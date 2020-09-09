defmodule JsonSchemaTestSuite.Draft7.ItemsTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|a schema given for items| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => %{"type" => "integer"}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid items|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test ~s|wrong type of items|, %{schema: schema} do
      refute valid?(schema, [1, "x"])
    end

    test ~s|ignores non-arrays|, %{schema: schema} do
      assert valid?(schema, %{"foo" => "bar"})
    end

    test ~s|JavaScript pseudo-array is valid|, %{schema: schema} do
      assert valid?(schema, %{"0" => "invalid", "length" => 1})
    end
  end

  describe ~s|an array of schemas for items| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => [%{"type" => "integer"}, %{"type" => "string"}]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|correct types|, %{schema: schema} do
      assert valid?(schema, [1, "foo"])
    end

    test ~s|wrong types|, %{schema: schema} do
      refute valid?(schema, ["foo", 1])
    end

    test ~s|incomplete array of items|, %{schema: schema} do
      assert valid?(schema, [1])
    end

    test ~s|array with additional items|, %{schema: schema} do
      assert valid?(schema, [1, "foo", true])
    end

    test ~s|empty array|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|JavaScript pseudo-array is valid|, %{schema: schema} do
      assert valid?(schema, %{"0" => "invalid", "1" => "valid", "length" => 2})
    end
  end

  describe ~s|items with boolean schema (true)| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => true},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|any array is valid|, %{schema: schema} do
      assert valid?(schema, [1, "foo", true])
    end

    test ~s|empty array is valid|, %{schema: schema} do
      assert valid?(schema, [])
    end
  end

  describe ~s|items with boolean schema (false)| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => false},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|any non-empty array is invalid|, %{schema: schema} do
      refute valid?(schema, [1, "foo", true])
    end

    test ~s|empty array is valid|, %{schema: schema} do
      assert valid?(schema, [])
    end
  end

  describe ~s|items with boolean schemas| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => [true, false]},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|array with one item is valid|, %{schema: schema} do
      assert valid?(schema, [1])
    end

    test ~s|array with two items is invalid|, %{schema: schema} do
      refute valid?(schema, [1, "foo"])
    end

    test ~s|empty array is valid|, %{schema: schema} do
      assert valid?(schema, [])
    end
  end

  describe ~s|items and subitems| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
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
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid items|, %{schema: schema} do
      assert valid?(schema, [
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test ~s|too many items|, %{schema: schema} do
      refute valid?(schema, [
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test ~s|too many sub-items|, %{schema: schema} do
      refute valid?(schema, [
               [%{"foo" => nil}, %{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test ~s|wrong item|, %{schema: schema} do
      refute valid?(schema, [
               %{"foo" => nil},
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test ~s|wrong sub-item|, %{schema: schema} do
      refute valid?(schema, [
               [%{}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}],
               [%{"foo" => nil}, %{"foo" => nil}]
             ])
    end

    test ~s|fewer items is valid|, %{schema: schema} do
      assert valid?(schema, [[%{"foo" => nil}], [%{"foo" => nil}]])
    end
  end

  describe ~s|nested items| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "items" => %{
                "items" => %{
                  "items" => %{"items" => %{"type" => "number"}, "type" => "array"},
                  "type" => "array"
                },
                "type" => "array"
              },
              "type" => "array"
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid nested array|, %{schema: schema} do
      assert valid?(schema, [[[[1]], [[2], [3]]], [[[4], [5], [6]]]])
    end

    test ~s|nested array with invalid type|, %{schema: schema} do
      refute valid?(schema, [[[["1"]], [[2], [3]]], [[[4], [5], [6]]]])
    end

    test ~s|not deep enough|, %{schema: schema} do
      refute valid?(schema, [[[1], [2], [3]], [[4], [5], [6]]])
    end
  end
end
