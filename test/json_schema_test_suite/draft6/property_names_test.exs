defmodule JsonSchemaTestSuite.Draft6.PropertyNamesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|propertyNames validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"propertyNames" => %{"maxLength" => 3}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|all property names valid|, %{schema: schema} do
      assert valid?(schema, %{"f" => %{}, "foo" => %{}})
    end

    test ~s|some property names invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => %{}, "foobar" => %{}})
    end

    test ~s|object without properties is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [1, 2, 3, 4])
    end

    test ~s|ignores strings|, %{schema: schema} do
      assert valid?(schema, "foobar")
    end

    test ~s|ignores other non-objects|, %{schema: schema} do
      assert valid?(schema, 12)
    end
  end

  describe ~s|propertyNames with boolean schema true| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"propertyNames" => true},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|object with any properties is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|empty object is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe ~s|propertyNames with boolean schema false| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"propertyNames" => false},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|object with any properties is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => 1})
    end

    test ~s|empty object is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end
end
