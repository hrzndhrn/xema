defmodule JsonSchemaTestSuite.Draft7.Optional.Format.UriTemplate do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "format: uri-template" do
    setup do
      %{schema: Xema.from_json_schema(%{"format" => "uri-template"})}
    end

    test "a valid uri-template", %{schema: schema} do
      assert valid?(schema, "http://example.com/dictionary/{term:1}/{term}")
    end

    test "an invalid uri-template", %{schema: schema} do
      refute valid?(schema, "http://example.com/dictionary/{term:1}/{term")
    end

    test "a valid uri-template without variables", %{schema: schema} do
      assert valid?(schema, "http://example.com/dictionary")
    end

    test "a valid relative uri-template", %{schema: schema} do
      assert valid?(schema, "dictionary/{term:1}/{term}")
    end
  end
end