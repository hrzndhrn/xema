defmodule Draft4.PatternPropertiesTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "patternProperties validates properties matching a regex" do
    setup do
      %{schema: Xema.new(:pattern_properties, %{"f.*o" => :integer})}
    end

    @tag :draft4
    @tag :pattern_properties
    test "a single valid match is valid", %{schema: schema} do
      data = %{foo: 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "multiple valid matches is valid", %{schema: schema} do
      data = %{foo: 1, foooooo: 2}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "a single invalid match is invalid", %{schema: schema} do
      data = %{foo: "bar", fooooo: 2}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "multiple invalid matches is invalid", %{schema: schema} do
      data = %{foo: "bar", foooooo: "baz"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "ignores arrays", %{schema: schema} do
      data = []
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "ignores strings", %{schema: schema} do
      data = ""
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert is_valid?(schema, data)
    end
  end

  describe "multiple simultaneous patternProperties are validated" do
    setup do
      %{
        schema:
          Xema.new(:pattern_properties, %{
            "a*" => :integer,
            "aaa*" => {:maximum, 20}
          })
      }
    end

    @tag :draft4
    @tag :pattern_properties
    test "a single valid match is valid", %{schema: schema} do
      data = %{a: 21}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "a simultaneous match is valid", %{schema: schema} do
      data = %{aaaa: 18}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "multiple matches is valid", %{schema: schema} do
      data = %{a: 21, aaaa: 18}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "an invalid due to one is invalid", %{schema: schema} do
      data = %{a: "bar"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    @tag :only
    test "an invalid due to the other is invalid", %{schema: schema} do
      data = %{aaaa: 31}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "an invalid due to both is invalid", %{schema: schema} do
      data = %{aaa: "foo", aaaa: 31}
      refute is_valid?(schema, data)
    end
  end

  describe "regexes are not anchored by default and are case sensitive" do
    setup do
      %{
        schema:
          Xema.new(:pattern_properties, %{
            "X_" => :string,
            "[0-9]{2,}" => :boolean
          })
      }
    end

    @tag :draft4
    @tag :pattern_properties
    test "non recognized members are ignored", %{schema: schema} do
      data = %{"answer 1": "42"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "recognized members are accounted for", %{schema: schema} do
      data = %{a31b: nil}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "regexes are case sensitive", %{schema: schema} do
      data = %{a_x_3: 3}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :pattern_properties
    test "regexes are case sensitive, 2", %{schema: schema} do
      data = %{a_X_3: 3}
      refute is_valid?(schema, data)
    end
  end
end
