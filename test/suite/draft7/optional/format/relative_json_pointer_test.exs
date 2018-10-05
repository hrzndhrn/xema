defmodule Draft7.Optional.Format.RelativeJsonPointerTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "validation of Relative JSON Pointers (RJP)" do
    setup do
      %{schema: Xema.new(:format, :relative_json_pointer)}
    end

    test "a valid upwards RJP", %{schema: schema} do
      data = "1"
      assert valid?(schema, data)
    end

    test "a valid downwards RJP", %{schema: schema} do
      data = "0/foo/bar"
      assert valid?(schema, data)
    end

    test "a valid up and then down RJP, with array index", %{schema: schema} do
      data = "2/0/baz/1/zip"
      assert valid?(schema, data)
    end

    test "a valid RJP taking the member or index name", %{schema: schema} do
      data = "0#"
      assert valid?(schema, data)
    end

    test "an invalid RJP that is a valid JSON Pointer", %{schema: schema} do
      data = "/foo/bar"
      refute valid?(schema, data)
    end
  end
end
