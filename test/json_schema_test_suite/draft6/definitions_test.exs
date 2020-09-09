defmodule JsonSchemaTestSuite.Draft6.DefinitionsTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|valid definition| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://json-schema.org/draft-06/schema#"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|valid definition schema|, %{schema: schema} do
      assert valid?(schema, %{"definitions" => %{"foo" => %{"type" => "integer"}}})
    end
  end

  describe ~s|invalid definition| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"$ref" => "http://json-schema.org/draft-06/schema#"},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|invalid definition schema|, %{schema: schema} do
      refute valid?(schema, %{"definitions" => %{"foo" => %{"type" => 1}}})
    end
  end
end
