defmodule JsonSchemaTestSuite.Draft4.PatternTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|pattern validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"pattern" => "^a*$"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|a matching pattern is valid|, %{schema: schema} do
      assert valid?(schema, "aaa")
    end

    test ~s|a non-matching pattern is invalid|, %{schema: schema} do
      refute valid?(schema, "abc")
    end

    test ~s|ignores booleans|, %{schema: schema} do
      assert valid?(schema, true)
    end

    test ~s|ignores integers|, %{schema: schema} do
      assert valid?(schema, 123)
    end

    test ~s|ignores floats|, %{schema: schema} do
      assert valid?(schema, 1.0)
    end

    test ~s|ignores objects|, %{schema: schema} do
      assert valid?(schema, %{})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, [])
    end

    test ~s|ignores null|, %{schema: schema} do
      assert valid?(schema, nil)
    end
  end

  describe ~s|pattern is not anchored| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"pattern" => "a+"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|matches a substring|, %{schema: schema} do
      assert valid?(schema, "xxaayy")
    end
  end
end
