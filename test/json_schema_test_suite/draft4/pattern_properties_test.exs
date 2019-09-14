defmodule JsonSchemaTestSuite.Draft4.PatternProperties do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "patternProperties validates properties matching a regex" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{"patternProperties" => %{"f.*o" => %{"type" => "integer"}}})
      }
    end

    test "a single valid match is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1})
    end

    test "multiple valid matches is valid", %{schema: schema} do
      assert valid?(schema, %{"foo" => 1, "foooooo" => 2})
    end

    test "a single invalid match is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar", "fooooo" => 2})
    end

    test "multiple invalid matches is invalid", %{schema: schema} do
      refute valid?(schema, %{"foo" => "bar", "foooooo" => "baz"})
    end

    test "ignores arrays", %{schema: schema} do
      assert valid?(schema, [])
    end

    test "ignores strings", %{schema: schema} do
      assert valid?(schema, "")
    end

    test "ignores other non-objects", %{schema: schema} do
      assert valid?(schema, 12)
    end
  end

  describe "multiple simultaneous patternProperties are validated" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "patternProperties" => %{"a*" => %{"type" => "integer"}, "aaa*" => %{"maximum" => 20}}
          })
      }
    end

    test "a single valid match is valid", %{schema: schema} do
      assert valid?(schema, %{"a" => 21})
    end

    test "a simultaneous match is valid", %{schema: schema} do
      assert valid?(schema, %{"aaaa" => 18})
    end

    test "multiple matches is valid", %{schema: schema} do
      assert valid?(schema, %{"a" => 21, "aaaa" => 18})
    end

    test "an invalid due to one is invalid", %{schema: schema} do
      refute valid?(schema, %{"a" => "bar"})
    end

    test "an invalid due to the other is invalid", %{schema: schema} do
      refute valid?(schema, %{"aaaa" => 31})
    end

    test "an invalid due to both is invalid", %{schema: schema} do
      refute valid?(schema, %{"aaa" => "foo", "aaaa" => 31})
    end
  end

  describe "regexes are not anchored by default and are case sensitive" do
    setup do
      %{
        schema:
          Xema.from_json_schema(%{
            "patternProperties" => %{
              "X_" => %{"type" => "string"},
              "[0-9]{2,}" => %{"type" => "boolean"}
            }
          })
      }
    end

    test "non recognized members are ignored", %{schema: schema} do
      assert valid?(schema, %{"answer 1" => "42"})
    end

    test "recognized members are accounted for", %{schema: schema} do
      refute valid?(schema, %{"a31b" => nil})
    end

    test "regexes are case sensitive", %{schema: schema} do
      assert valid?(schema, %{"a_x_3" => 3})
    end

    test "regexes are case sensitive, 2", %{schema: schema} do
      refute valid?(schema, %{"a_X_3" => 3})
    end
  end
end