defmodule Draft6.PatternPropertiesTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "patternProperties validates properties matching a regex" do
    setup do
      %{schema: Xema.new(pattern_properties: %{"f.*o" => :integer})}
    end

    test "a single valid match is valid", %{schema: schema} do
      data = %{foo: 1}
      assert valid?(schema, data)
    end

    test "multiple valid matches is valid", %{schema: schema} do
      data = %{foo: 1, foooooo: 2}
      assert valid?(schema, data)
    end

    test "a single invalid match is invalid", %{schema: schema} do
      data = %{foo: "bar", fooooo: 2}
      refute valid?(schema, data)
    end

    test "multiple invalid matches is invalid", %{schema: schema} do
      data = %{foo: "bar", foooooo: "baz"}
      refute valid?(schema, data)
    end

    test "ignores arrays", %{schema: schema} do
      data = ["foo"]
      assert valid?(schema, data)
    end

    test "ignores strings", %{schema: schema} do
      data = "foo"
      assert valid?(schema, data)
    end

    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert valid?(schema, data)
    end
  end

  describe "multiple simultaneous patternProperties are validated" do
    setup do
      %{
        schema: Xema.new(pattern_properties: %{"a*" => :integer, "aaa*" => [maximum: 20]})
      }
    end

    test "a single valid match is valid", %{schema: schema} do
      data = %{a: 21}
      assert valid?(schema, data)
    end

    test "a simultaneous match is valid", %{schema: schema} do
      data = %{aaaa: 18}
      assert valid?(schema, data)
    end

    test "multiple matches is valid", %{schema: schema} do
      data = %{a: 21, aaaa: 18}
      assert valid?(schema, data)
    end

    test "an invalid due to one is invalid", %{schema: schema} do
      data = %{a: "bar"}
      refute valid?(schema, data)
    end

    test "an invalid due to the other is invalid", %{schema: schema} do
      data = %{aaaa: 31}
      refute valid?(schema, data)
    end

    test "an invalid due to both is invalid", %{schema: schema} do
      data = %{aaa: "foo", aaaa: 31}
      refute valid?(schema, data)
    end
  end

  describe "regexes are not anchored by default and are case sensitive" do
    setup do
      %{
        schema: Xema.new(pattern_properties: %{"X_" => :string, "[0-9]{2,}" => :boolean})
      }
    end

    test "non recognized members are ignored", %{schema: schema} do
      data = %{"answer 1": "42"}
      assert valid?(schema, data)
    end

    test "recognized members are accounted for", %{schema: schema} do
      data = %{a31b: nil}
      refute valid?(schema, data)
    end

    test "regexes are case sensitive", %{schema: schema} do
      data = %{a_x_3: 3}
      assert valid?(schema, data)
    end

    test "regexes are case sensitive, 2", %{schema: schema} do
      data = %{a_X_3: 3}
      refute valid?(schema, data)
    end
  end

  describe "patternProperties with boolean schemas" do
    setup do
      %{schema: Xema.new(pattern_properties: %{"b.*" => false, "f.*" => true})}
    end

    test "object with property matching schema true is valid", %{schema: schema} do
      data = %{foo: 1}
      assert valid?(schema, data)
    end

    test "object with property matching schema false is invalid", %{
      schema: schema
    } do
      data = %{bar: 2}
      refute valid?(schema, data)
    end

    test "object with both properties is invalid", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      refute valid?(schema, data)
    end

    test "empty object is valid", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end
  end
end
