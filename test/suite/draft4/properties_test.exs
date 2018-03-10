defmodule Draft4.PropertiesTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "object properties validation" do
    setup do
      %{schema: Xema.new(:properties, %{bar: :string, foo: :integer})}
    end

    @tag :draft4
    @tag :properties
    test "both properties present and valid is valid", %{schema: schema} do
      data = %{bar: "baz", foo: 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "one property invalid is invalid", %{schema: schema} do
      data = %{bar: %{}, foo: 1}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "both properties invalid is invalid", %{schema: schema} do
      data = %{bar: %{}, foo: []}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "doesn't invalidate other properties", %{schema: schema} do
      data = %{quux: []}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "ignores arrays", %{schema: schema} do
      data = []
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert is_valid?(schema, data)
    end
  end

  describe "properties, patternProperties, additionalProperties interaction" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            additional_properties: :integer,
            pattern_properties: %{"f.o" => {:min_items, 2}},
            properties: %{bar: :list, foo: {:list, max_items: 3}}
          )
      }
    end

    @tag :draft4
    @tag :properties
    test "property validates property", %{schema: schema} do
      data = %{foo: [1, 2]}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "property invalidates property", %{schema: schema} do
      data = %{foo: [1, 2, 3, 4]}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "patternProperty invalidates property", %{schema: schema} do
      data = %{foo: []}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "patternProperty validates nonproperty", %{schema: schema} do
      data = %{fxo: [1, 2]}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "patternProperty invalidates nonproperty", %{schema: schema} do
      data = %{fxo: []}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "additionalProperty ignores property", %{schema: schema} do
      data = %{bar: []}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "additionalProperty validates others", %{schema: schema} do
      data = %{quux: 3}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :properties
    test "additionalProperty invalidates others", %{schema: schema} do
      data = %{quux: "foo"}
      refute is_valid?(schema, data)
    end
  end
end
