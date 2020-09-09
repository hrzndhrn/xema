defmodule JsonSchemaTestSuite.Draft4.AdditionalItemsTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|additionalItems as schema| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalItems" => %{"type" => "integer"}, "items" => [%{}]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|additional items match schema|, %{schema: schema} do
      assert valid?(schema, [nil, 2, 3, 4])
    end

    test ~s|additional items do not match schema|, %{schema: schema} do
      refute valid?(schema, [nil, 2, 3, "foo"])
    end
  end

  describe ~s|items is schema, no additionalItems| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalItems" => false, "items" => %{}},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|all items match schema|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3, 4, 5])
    end
  end

  describe ~s|array of items with no additionalItems| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalItems" => false, "items" => [%{}, %{}, %{}]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|empty array|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|fewer number of items present (1)|, %{schema: schema} do
      assert valid?(schema, [1])
    end

    test ~s|fewer number of items present (2)|, %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test ~s|equal number of items present|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test ~s|additional items are not permitted|, %{schema: schema} do
      refute valid?(schema, [1, 2, 3, 4])
    end
  end

  describe ~s|additionalItems as false without items| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"additionalItems" => false},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|items defaults to empty schema so everything is valid|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3, 4, 5])
    end

    test ~s|ignores non-arrays|, %{schema: schema} do
      assert valid?(schema, %{"foo" => "bar"})
    end
  end

  describe ~s|additionalItems are allowed by default| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"items" => [%{"type" => "integer"}]},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|only the first item is validated|, %{schema: schema} do
      assert valid?(schema, [1, "foo", false])
    end
  end

  describe ~s|additionalItems should not look in applicators, valid case| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalItems" => %{"type" => "boolean"},
              "allOf" => [%{"items" => [%{"type" => "integer"}]}]
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|items defined in allOf are not examined|, %{schema: schema} do
      assert valid?(schema, [1, nil])
    end
  end

  describe ~s|additionalItems should not look in applicators, invalid case| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "additionalItems" => %{"type" => "boolean"},
              "allOf" => [%{"items" => [%{"type" => "integer"}, %{"type" => "string"}]}],
              "items" => [%{"type" => "integer"}]
            },
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|items defined in allOf are not examined|, %{schema: schema} do
      refute valid?(schema, [1, "hello"])
    end
  end
end
