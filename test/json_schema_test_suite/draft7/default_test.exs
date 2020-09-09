defmodule JsonSchemaTestSuite.Draft7.DefaultTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|invalid type for default| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"foo" => %{"default" => [], "type" => "integer"}}},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid when property is specified|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 13})
    end

    test ~s|still valid when the invalid default is used|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe ~s|invalid string value for default| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "properties" => %{
                "bar" => %{"default" => "bad", "minLength" => 4, "type" => "string"}
              }
            },
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|valid when property is specified|, %{schema: schema} do
      assert valid?(schema, %{"bar" => "good"})
    end

    test ~s|still valid when the invalid default is used|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end
end
