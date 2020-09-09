defmodule JsonSchemaTestSuite.Draft7.Optional.Format.RegexTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of regular expressions| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "regex"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|a valid regular expression|, %{schema: schema} do
      assert valid?(schema, "([abc])+\\s+$")
    end

    test ~s|a regular expression with unclosed parens is invalid|, %{schema: schema} do
      refute valid?(schema, "^(abc]")
    end
  end
end
