defmodule JsonSchemaTestSuite.Draft7.Optional.Format.RegexTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of regular expressions" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "regex"},
            draft: "draft7"
          )
      }
    end

    test "a valid regular expression", %{schema: schema} do
      assert valid?(schema, "([abc])+\\s+$")
    end

    test "a regular expression with unclosed parens is invalid", %{schema: schema} do
      refute valid?(schema, "^(abc]")
    end
  end
end
