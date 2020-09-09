defmodule JsonSchemaTestSuite.Draft7.Optional.Format.UriTemplateTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|format: uri-template| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "uri-template"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|a valid uri-template|, %{schema: schema} do
      assert valid?(schema, "http://example.com/dictionary/{term:1}/{term}")
    end

    test ~s|an invalid uri-template|, %{schema: schema} do
      refute valid?(schema, "http://example.com/dictionary/{term:1}/{term")
    end

    test ~s|a valid uri-template without variables|, %{schema: schema} do
      assert valid?(schema, "http://example.com/dictionary")
    end

    test ~s|a valid relative uri-template|, %{schema: schema} do
      assert valid?(schema, "dictionary/{term:1}/{term}")
    end
  end
end
