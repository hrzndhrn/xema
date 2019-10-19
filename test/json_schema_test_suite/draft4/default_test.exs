defmodule JsonSchemaTestSuite.Draft4.DefaultTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "invalid type for default" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"properties" => %{"foo" => %{"default" => [], "type" => "integer"}}},
            draft: "draft4"
          )
      }
    end

    test "valid when property is specified", %{schema: schema} do
      assert valid?(schema, %{"foo" => 13})
    end

    test "still valid when the invalid default is used", %{schema: schema} do
      assert valid?(schema, %{})
    end
  end

  describe "invalid string value for default" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "properties" => %{
                "bar" => %{"default" => "bad", "minLength" => 4, "type" => "string"}
              }
            },
            draft: "draft4"
          )
      }
    end

    test "valid when property is specified", %{schema: schema} do
      assert valid?(schema, %{"bar" => "good"})
    end

    test "still valid when the invalid default is used", %{schema: schema} do
      assert valid?(schema, %{})
    end
  end
end
