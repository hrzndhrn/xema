defmodule JsonSchemaTestSuite.Draft7.Optional.Format.RelativeJsonPointerTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of Relative JSON Pointers (RJP)| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "relative-json-pointer"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|a valid upwards RJP|, %{schema: schema} do
      assert valid?(schema, "1")
    end

    test ~s|a valid downwards RJP|, %{schema: schema} do
      assert valid?(schema, "0/foo/bar")
    end

    test ~s|a valid up and then down RJP, with array index|, %{schema: schema} do
      assert valid?(schema, "2/0/baz/1/zip")
    end

    test ~s|a valid RJP taking the member or index name|, %{schema: schema} do
      assert valid?(schema, "0#")
    end

    test ~s|an invalid RJP that is a valid JSON Pointer|, %{schema: schema} do
      refute valid?(schema, "/foo/bar")
    end

    test ~s|negative prefix|, %{schema: schema} do
      refute valid?(schema, "-1/foo/bar")
    end
  end
end
