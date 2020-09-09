defmodule JsonSchemaTestSuite.Draft6.PatternPropertiesTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|patternProperties validates properties matching a regex| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"patternProperties" => %{"f.*o" => %{"type" => "integer"}}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|a single valid match is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|multiple valid matches is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1, "foooooo" => 2})
    end

    test ~s|a single invalid match is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar", "fooooo" => 2})
    end

    test ~s|multiple invalid matches is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar", "foooooo" => "baz"})
    end

    test ~s|ignores arrays|, %{schema: schema} do
      assert valid?(schema, ["foo"])
    end

    test ~s|ignores strings|, %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test ~s|ignores other non-objects|, %{schema: schema} do
      assert valid?(schema, 12)
    end
  end

  describe ~s|multiple simultaneous patternProperties are validated| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "patternProperties" => %{
                "a*" => %{"type" => "integer"},
                "aaa*" => %{"maximum" => 20}
              }
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|a single valid match is valid|, %{schema: schema} do
      assert valid?(schema, %{"a" => 21})
    end

    test ~s|a simultaneous match is valid|, %{schema: schema} do
      assert valid?(schema, %{"aaaa" => 18})
    end

    test ~s|multiple matches is valid|, %{schema: schema} do
      assert valid?(schema, %{"a" => 21, "aaaa" => 18})
    end

    test ~s|an invalid due to one is invalid|, %{schema: schema} do
      refute valid?(schema, %{"a" => "bar"})
    end

    test ~s|an invalid due to the other is invalid|, %{schema: schema} do
      refute valid?(schema, %{"aaaa" => 31})
    end

    test ~s|an invalid due to both is invalid|, %{schema: schema} do
      refute valid?(schema, %{"aaa" => "foo", "aaaa" => 31})
    end
  end

  describe ~s|regexes are not anchored by default and are case sensitive| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{
              "patternProperties" => %{
                "X_" => %{"type" => "string"},
                "[0-9]{2,}" => %{"type" => "boolean"}
              }
            },
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|non recognized members are ignored|, %{schema: schema} do
      assert valid?(schema, %{"answer 1" => "42"})
    end

    test ~s|recognized members are accounted for|, %{schema: schema} do
      refute valid?(schema, %{"a31b" => nil})
    end

    test ~s|regexes are case sensitive|, %{schema: schema} do
      assert valid?(schema, %{"a_x_3" => 3})
    end

    test ~s|regexes are case sensitive, 2|, %{schema: schema} do
      refute valid?(schema, %{"a_X_3" => 3})
    end
  end

  describe ~s|patternProperties with boolean schemas| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"patternProperties" => %{"b.*" => false, "f.*" => true}},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|object with property matching schema true is valid|, %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test ~s|object with property matching schema false is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2})
    end

    test ~s|object with both properties is invalid|, %{schema: schema} do
      refute valid?(schema, %{"bar" => 2, "foo" => 1})
    end

    test ~s|object with a property matching both true and false is invalid|, %{schema: schema} do
      refute valid?(schema, %{"foobar" => 1})
    end

    test ~s|empty object is valid|, %{schema: schema} do
      assert valid?(schema, %{})
    end
  end
end
