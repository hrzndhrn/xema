defmodule JsonSchemaTestSuite.Draft6.ContainsTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|contains keyword validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"contains" => %{"minimum" => 5}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|array with item matching schema (5) is valid|, %{schema: schema} do
      assert valid?(schema, [3, 4, 5])
    end

    test ~s|array with item matching schema (6) is valid|, %{schema: schema} do
      assert valid?(schema, [3, 4, 6])
    end

    test ~s|array with two items matching schema (5, 6) is valid|, %{schema: schema} do
      assert valid?(schema, [3, 4, 5, 6])
    end

    test ~s|array without items matching schema is invalid|, %{schema: schema} do
      refute valid?(schema, [2, 3, 4])
    end

    test ~s|empty array is invalid|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|not array is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe ~s|contains keyword with const keyword| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"contains" => %{"const" => 5}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|array with item 5 is valid|, %{schema: schema} do
      assert valid?(schema, [3, 4, 5])
    end

    test ~s|array with two items 5 is valid|, %{schema: schema} do
      assert valid?(schema, [3, 4, 5, 5])
    end

    test ~s|array without item 5 is invalid|, %{schema: schema} do
      refute valid?(schema, [1, 2, 3, 4])
    end
  end

  describe ~s|contains keyword with boolean schema true| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"contains" => true},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|any non-empty array is valid|, %{schema: schema} do
      assert valid?(schema, ["foo"])
    end

    test ~s|empty array is invalid|, %{schema: schema} do
      refute valid?(schema, [])
    end
  end

  describe ~s|contains keyword with boolean schema false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"contains" => false},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|any non-empty array is invalid|, %{schema: schema} do
      refute valid?(schema, ["foo"])
    end

    test ~s|empty array is invalid|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|non-arrays are valid|, %{schema: schema} do
      assert valid?(schema, "contains does not apply to strings")
    end
  end

  describe ~s|items + contains| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"contains" => %{"multipleOf" => 3}, "items" => %{"multipleOf" => 2}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|matches items, does not match contains|, %{schema: schema} do
      refute valid?(schema, [2, 4, 8])
    end

    test ~s|does not match items, matches contains|, %{schema: schema} do
      refute valid?(schema, [3, 6, 9])
    end

    test ~s|matches both items and contains|, %{schema: schema} do
      assert valid?(schema, [6, 12])
    end

    test ~s|matches neither items nor contains|, %{schema: schema} do
      refute valid?(schema, [1, 5])
    end
  end
end
