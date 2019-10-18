defmodule JsonSchemaTestSuite.Draft4.DefinitionsTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "valid definition" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://json-schema.org/draft-04/schema#"},
            draft: "draft4"
          )
      }
    end

    test "valid definition schema", %{schema: schema} do
      assert valid?(schema, %{"definitions" => %{"foo" => %{"type" => "integer"}}})
    end
  end

  describe "invalid definition" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://json-schema.org/draft-04/schema#"},
            draft: "draft4"
          )
      }
    end

    test "invalid definition schema", %{schema: schema} do
      refute valid?(schema, %{"definitions" => %{"foo" => %{"type" => 1}}})
    end
  end
end
