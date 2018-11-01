defmodule Draft6.PropertiesTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "object properties validation" do
    setup do
      %{schema: Xema.new(properties: %{bar: :string, foo: :integer})}
    end

    test "both properties present and valid is valid", %{schema: schema} do
      data = %{bar: "baz", foo: 1}
      assert valid?(schema, data)
    end

    test "one property invalid is invalid", %{schema: schema} do
      data = %{bar: %{}, foo: 1}
      refute valid?(schema, data)
    end

    test "both properties invalid is invalid", %{schema: schema} do
      data = %{bar: %{}, foo: []}
      refute valid?(schema, data)
    end

    test "doesn't invalidate other properties", %{schema: schema} do
      data = %{quux: []}
      assert valid?(schema, data)
    end

    test "ignores arrays", %{schema: schema} do
      data = []
      assert valid?(schema, data)
    end

    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert valid?(schema, data)
    end
  end

  describe "properties, patternProperties, additionalProperties interaction" do
    setup do
      %{
        schema:
          Xema.new(
            additional_properties: :integer,
            pattern_properties: %{"f.o" => [min_items: 2]},
            properties: %{bar: :list, foo: {:list, [max_items: 3]}}
          )
      }
    end

    test "property validates property", %{schema: schema} do
      data = %{foo: [1, 2]}
      assert valid?(schema, data)
    end

    test "property invalidates property", %{schema: schema} do
      data = %{foo: [1, 2, 3, 4]}
      refute valid?(schema, data)
    end

    test "patternProperty invalidates property", %{schema: schema} do
      data = %{foo: []}
      refute valid?(schema, data)
    end

    test "patternProperty validates nonproperty", %{schema: schema} do
      data = %{fxo: [1, 2]}
      assert valid?(schema, data)
    end

    test "patternProperty invalidates nonproperty", %{schema: schema} do
      data = %{fxo: []}
      refute valid?(schema, data)
    end

    test "additionalProperty ignores property", %{schema: schema} do
      data = %{bar: []}
      assert valid?(schema, data)
    end

    test "additionalProperty validates others", %{schema: schema} do
      data = %{quux: 3}
      assert valid?(schema, data)
    end

    test "additionalProperty invalidates others", %{schema: schema} do
      data = %{quux: "foo"}
      refute valid?(schema, data)
    end
  end

  describe "properties with boolean schema" do
    setup do
      %{schema: Xema.new(properties: %{bar: false, foo: true})}
    end

    test "no property present is valid", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end

    test "only 'true' property present is valid", %{schema: schema} do
      data = %{foo: 1}
      assert valid?(schema, data)
    end

    test "only 'false' property present is invalid", %{schema: schema} do
      data = %{bar: 2}
      refute valid?(schema, data)
    end

    test "both properties present is invalid", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      refute valid?(schema, data)
    end
  end
end
