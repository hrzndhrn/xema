defmodule Draft7.Optional.Format.RegexTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "validation of regular expressions" do
    setup do
      %{schema: Xema.new(:format, :regex)}
    end

    test "a valid regular expression", %{schema: schema} do
      data = "([abc])+\\s+$"
      assert valid?(schema, data)
    end

    test "a regular expression with unclosed parens is invalid", %{
      schema: schema
    } do
      data = "^(abc]"
      refute valid?(schema, data)
    end
  end
end
