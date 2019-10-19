defmodule JsonSchemaTestSuite.Draft7.Optional.Format.RelativeJsonPointerTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of Relative JSON Pointers (RJP)" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "relative-json-pointer"},
            draft: "draft7"
          )
      }
    end

    test "a valid upwards RJP", %{schema: schema} do
      assert valid?(schema, "1")
    end

    test "a valid downwards RJP", %{schema: schema} do
      assert valid?(schema, "0/foo/bar")
    end

    test "a valid up and then down RJP, with array index", %{schema: schema} do
      assert valid?(schema, "2/0/baz/1/zip")
    end

    test "a valid RJP taking the member or index name", %{schema: schema} do
      assert valid?(schema, "0#")
    end

    test "an invalid RJP that is a valid JSON Pointer", %{schema: schema} do
      refute valid?(schema, "/foo/bar")
    end
  end
end
