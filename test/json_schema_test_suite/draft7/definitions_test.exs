defmodule JsonSchemaTestSuite.Draft7.Definitions do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "valid definition" do
    setup do
      %{schema: Xema.from_json_schema(%{"$ref" => "http://json-schema.org/draft-07/schema#"})}
    end

    test "valid definition schema", %{schema: schema} do
      assert valid?(schema, %{"definitions" => %{"foo" => %{"type" => "integer"}}})
    end
  end

  describe "invalid definition" do
    setup do
      %{schema: Xema.from_json_schema(%{"$ref" => "http://json-schema.org/draft-07/schema#"})}
    end

    test "invalid definition schema", %{schema: schema} do
      refute valid?(schema, %{"definitions" => %{"foo" => %{"type" => 1}}})
    end
  end
end
