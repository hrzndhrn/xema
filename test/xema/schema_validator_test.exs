defmodule Xema.SchemaValidatorTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  import Xema

  describe "schema type any:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :any."

      assert_raise SchemaError, expected, fn ->
        xema(:any, foo: false)
      end
    end

    test "keyword enum with invalid value" do
      expected = "enum must be a list."

      assert_raise SchemaError, expected, fn ->
        xema(:any, enum: "foo")
      end
    end

    test "keyword enum with empty list" do
      expected = "enum can not be an empty list."

      assert_raise SchemaError, expected, fn ->
        xema(:any, enum: [])
      end
    end

    test "keyword enum with duplicate entries" do
      expected = "enum must be unique."

      assert_raise SchemaError, expected, fn ->
        xema(:any, enum: [1, 2, 3, 2])
      end
    end

    test "keyword not without a schema" do
      expected = ~s("foo" is not a valid type.)

      assert_raise SchemaError, expected, fn ->
        xema(:any, not: "foo")
      end
    end

    test "keyword all_of without a list" do
      expected = "all_of has to be a list."

      assert_raise SchemaError, expected, fn ->
        xema(:any, all_of: "foo")
      end
    end

    test "keyword all_of with an invalid list" do
      expected = ~s("foo" is not a valid type.)

      assert_raise SchemaError, expected, fn ->
        xema(:any, all_of: [:integer, "foo"])
      end
    end

    test "keyword any_of without a list" do
      expected = "any_of has to be a list."

      assert_raise SchemaError, expected, fn ->
        xema(:any, any_of: "foo")
      end
    end

    test "keyword any_of with an invalid list" do
      expected = ~s("foo" is not a valid type.)

      assert_raise SchemaError, expected, fn ->
        xema(:any, any_of: [:integer, "foo"])
      end
    end
  end

  describe "schema type boolean:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :boolean."

      assert_raise SchemaError, expected, fn ->
        xema(:boolean, foo: false)
      end
    end

    test "supported keyword" do
      assert xema(:boolean, as: :bool) == %Xema{type: %Xema.Schema{type: :boolean, as: :bool}}
    end
  end

  describe "schema type list:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :list."

      assert_raise SchemaError, expected, fn ->
        xema(:list, foo: false)
      end
    end

    test "keyword additional_items without items" do
      expected = "additional_items has no effect if items not set."

      assert_raise SchemaError, expected, fn ->
        xema(:list, additional_items: false)
      end
    end

    test "keyword additional_items with items set to schema" do
      expected = "additional_items has no effect if items is not a list."

      assert_raise SchemaError, expected, fn ->
        xema(:list, items: :string, additional_items: false)
      end
    end

    test "keyword additional_items with invalid value" do
      expected = ~s("foo" is not a valid type.)

      assert_raise SchemaError, expected, fn ->
        xema(:list, items: [:string], additional_items: "foo")
      end
    end

    test "keyword additional_items with invalid schema" do
      expected = ~s(Expected an Integer for minimum, got "1".)

      assert_raise SchemaError, expected, fn ->
        xema(
          :list,
          items: [:string],
          additional_items: {:integer, minimum: "1"}
        )
      end
    end

    test "keyword items with a wrong type" do
      expected = ~s(Expected a schema or a list of schemas, got "foo".)

      assert_raise SchemaError, expected, fn ->
        xema(:list, items: "foo")
      end
    end

    test "keyword max_items with a wrong type" do
      expected = ~s(Expected a non negative integer for max_items, got "foo".)

      assert_raise SchemaError, expected, fn ->
        xema(:list, max_items: "foo")
      end
    end

    test "keyword max_items with a negative integer" do
      expected = ~s(Expected a non negative integer for max_items, got -1.)

      assert_raise SchemaError, expected, fn ->
        xema(:list, max_items: -1)
      end
    end

    test "keyword min_items with a wrong type" do
      expected = ~s(Expected a non negative integer for min_items, got "foo".)

      assert_raise SchemaError, expected, fn ->
        xema(:list, min_items: "foo")
      end
    end

    test "keyword min_items with a negative integer" do
      expected = ~s(Expected a non negative integer for min_items, got -2.)

      assert_raise SchemaError, expected, fn ->
        xema(:list, min_items: -2)
      end
    end
  end

  describe "schema type map:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :map."

      assert_raise SchemaError, expected, fn ->
        xema(:map, foo: false)
      end
    end

    test "keyword additional_properties without properties" do
      expected = "additional_properties has no effect if properties not set."

      assert_raise SchemaError, expected, fn ->
        xema(:map, additional_properties: false)
      end
    end

    test "keyword additional_properties with properties set to schema" do
      expected = "additional_properties has no effect if properties is not a map."

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: :string, additional_properties: false)
      end
    end

    test "keyword additional_properties with invalid value" do
      expected = ~s("foo" is not a valid type.)

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{a: :string}, additional_properties: "foo")
      end
    end

    test "keyword additional_properties with invalid schema" do
      expected = ~s(Expected an Integer for minimum, got "1".)

      assert_raise SchemaError, expected, fn ->
        xema(
          :map,
          properties: %{a: :string},
          additional_properties: {:integer, minimum: "1"}
        )
      end
    end

    test "keyword dependencies with inavalid value" do
      expected = "dependencies must be a map."

      assert_raise SchemaError, expected, fn ->
        xema(:map, dependencies: "invalid")
      end
    end

    test "keyword dependencies with invalid property" do
      expected = ~s("invalid" is not a valid type.)

      assert_raise SchemaError, expected, fn ->
        xema(:map, dependencies: %{foo: "invalid"})
      end
    end

    test "keyword max_properties with a wrong type" do
      expected = ~s(Expected a non negative integer for max_properties, got "foo".)

      assert_raise SchemaError, expected, fn ->
        xema(:map, max_properties: "foo")
      end
    end

    test "keyword max_properties with a negative integer" do
      expected = ~s(Expected a non negative integer for max_properties, got -2.)

      assert_raise SchemaError, expected, fn ->
        xema(:map, max_properties: -2)
      end
    end

    test "keyword min_properties with a wrong type" do
      expected = ~s(Expected a non negative integer for min_properties, got "foo".)

      assert_raise SchemaError, expected, fn ->
        xema(:map, min_properties: "foo")
      end
    end

    test "keyword min_properties with a negative integer" do
      expected = ~s(Expected a non negative integer for min_properties, got -2.)

      assert_raise SchemaError, expected, fn ->
        xema(:map, min_properties: -2)
      end
    end

    test "keyword properties with a wrong type" do
      expected = ~s(Expected a map for properties, got 12.)

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: 12)
      end
    end

    test "keyword properties with a wrong key" do
      expected = "Expected a string or atom for key in properties, got 7."

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{7 => :string})
      end
    end

    test "keyword pattern_properties with a wrong type" do
      expected = ~s(Expected a map for pattern_properties, got 12.)

      assert_raise SchemaError, expected, fn ->
        xema(:map, pattern_properties: 12)
      end
    end

    test "keyword pattern_properties with a wrong key" do
      expected = "Expected a regular expression for key in pattern_properties, got :a."

      assert_raise SchemaError, expected, fn ->
        xema(:map, pattern_properties: %{a: :string})
      end
    end
  end

  describe "schema type number:" do
    # unsupported keyword

    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :number."

      assert_raise SchemaError, expected, fn ->
        xema(:number, foo: false)
      end
    end

    # Keyword: exclusive_maximum

    @tag :number
    @tag :exclusive_maximum
    test "keyword exclusive_maximum with a wrong type and undefined maximum" do
      expected = ~s(Expected a number for exclusive_maximum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_maximum: "1")
      end
    end

    @tag :number
    @tag :exclusive_maximum
    test "keyword exclusive_maximum with a wrong type and defined maximum" do
      expected = ~s(Expected a boolean for exclusive_maximum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_maximum: "1", maximum: 1)
      end
    end

    @tag :number
    @tag :exclusive_maximum
    test "keyword exclusive_maximum as boolean and undefined maximum" do
      expected = ~s(No maximum value found for exclusive_maximum.)

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_maximum: true)
      end
    end

    @tag :number
    @tag :exclusive_maximum
    test "keyword exclusive_maximum as number and defined maximum" do
      expected = ~s(The exclusive_maximum overwrites maximum.)

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_maximum: 1, maximum: 1)
      end
    end

    # Keyword: exclusive_minimum

    test "keyword exclusive_minimum with a wrong type and undefined minimum" do
      expected = ~s(Expected a number for exclusive_minimum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_minimum: "1")
      end
    end

    test "keyword exclusive_minimum with a wrong type and defined minimum" do
      expected = ~s(Expected a boolean for exclusive_minimum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_minimum: "1", minimum: 1)
      end
    end

    test "keyword exclusive_minimum as boolean and undefined minimum" do
      expected = ~s(No minimum value found for exclusive_minimum.)

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_minimum: true)
      end
    end

    test "keyword exclusive_minimum as number and defined minimum" do
      expected = ~s(The exclusive_minimum overwrites minimum.)

      assert_raise SchemaError, expected, fn ->
        xema(:number, exclusive_minimum: 1, minimum: 1)
      end
    end

    test "keyword maximum with a wrong type" do
      expected = ~s(Expected a number for maximum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:number, maximum: "5", minimum: 1)
      end
    end

    # Keyword: minimum

    test "keyword minimum with a wrong type" do
      expected = ~s(Expected a number for minimum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:number, minimum: "5")
      end

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{foo: {:number, minimum: "5"}})
      end
    end

    test "keyword multiple_of with a wrong type" do
      msg = ~s(Expected a number for multiple_of, got "1".)

      assert_raise SchemaError, msg, fn ->
        xema(:number, multiple_of: "1")
      end
    end

    test "keyword multiple_of with too small value" do
      msg = ~s(multiple_of must be strictly greater than 0.)

      assert_raise SchemaError, msg, fn ->
        xema(:number, multiple_of: 0)
      end
    end

    test "keyword enum with invalid entries" do
      msg = "Entries of enum have to be Integers or Floats."

      assert_raise SchemaError, msg, fn ->
        xema(:number, enum: [1, "two"])
      end
    end
  end

  describe "schema type string:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :string."

      assert_raise SchemaError, expected, fn ->
        xema(:string, foo: false)
      end
    end

    test "keyword enum with invalid entries" do
      expected = "Entries of enum have to be Strings."

      assert_raise SchemaError, expected, fn ->
        xema(:string, enum: ["one", 2])
      end
    end

    test "keyword max_length with a wrong type" do
      expected = "Expected a non negative integer for max_length, got 1.1."

      assert_raise SchemaError, expected, fn ->
        xema(:string, max_length: 1.1)
      end
    end

    test "keyword max_length with a negative integer" do
      expected = "Expected a non negative integer for max_length, got -1."

      assert_raise SchemaError, expected, fn ->
        xema(:string, max_length: -1)
      end
    end

    test "keyword min_length with a wrong type" do
      expected = "Expected a non negative integer for min_length, got [1]."

      assert_raise SchemaError, expected, fn ->
        xema(:string, min_length: [1])
      end
    end

    test "keyword min_length with a negative integer" do
      expected = "Expected a non negative integer for min_length, got -1."

      assert_raise SchemaError, expected, fn ->
        xema(:string, min_length: -1)
      end
    end

    test "keyword pattern with a wrong type" do
      expected = ~s(Expected a regular expression for pattern, got %{}.)

      assert_raise SchemaError, expected, fn ->
        xema(:string, pattern: %{})
      end
    end
  end

  describe "schema type integer:" do
    # unsupported keyword

    @tag :integer
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :integer."

      assert_raise SchemaError, expected, fn ->
        xema(:integer, foo: false)
      end
    end

    # Keyword: exclusive_maximum

    @tag :integer
    @tag :exclusive_maximum
    test "keyword exclusive_maximum with a wrong type and undefined maximum" do
      expected = ~s(Expected a integer for exclusive_maximum, got 1.1)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_maximum: 1.1)
      end
    end

    @tag :integer
    @tag :exclusive_maximum
    test "keyword exclusive_maximum with a wrong type and defined maximum" do
      expected = ~s(Expected a boolean for exclusive_maximum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_maximum: "1", maximum: 1)
      end
    end

    @tag :integer
    @tag :exclusive_maximum
    test "keyword exclusive_maximum as boolean and undefined maximum" do
      expected = ~s(No maximum value found for exclusive_maximum.)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_maximum: true)
      end
    end

    @tag :integer
    @tag :exclusive_maximum
    test "keyword exclusive_maximum as number and defined maximum" do
      expected = ~s(The exclusive_maximum overwrites maximum.)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_maximum: 1, maximum: 1)
      end
    end

    # Keyword: exclusive_minimum

    @tag :integer
    @tag :exclusive_minimum
    test "keyword exclusive_minimum with a wrong type and undefined minimum" do
      expected = ~s(Expected a integer for exclusive_minimum, got 1.2)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_minimum: 1.2)
      end
    end

    @tag :integer
    @tag :exclusive_minimum
    test "keyword exclusive_minimum with a wrong type and defined minimum" do
      expected = ~s(Expected a boolean for exclusive_minimum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_minimum: "1", minimum: 1)
      end
    end

    @tag :integer
    @tag :exclusive_minimum
    test "keyword exclusive_minimum as boolean and undefined minimum" do
      expected = ~s(No minimum value found for exclusive_minimum.)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_minimum: true)
      end
    end

    @tag :integer
    @tag :exclusive_minimum
    test "keyword exclusive_minimum as number and defined minimum" do
      expected = ~s(The exclusive_minimum overwrites minimum.)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, exclusive_minimum: 1, minimum: 1)
      end
    end

    @tag :integer
    @tag :maximum
    test "keyword maximum with a wrong type" do
      expected = ~s(Expected an Integer for maximum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, maximum: "5")
      end
    end

    test "keyword minimum with a wrong type" do
      expected = ~s(Expected an Integer for minimum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, minimum: "5")
      end

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{foo: {:integer, minimum: "5"}})
      end
    end

    test "keyword multiple_of with a wrong type" do
      msg = ~s(Expected an Integer for multiple_of, got "1".)

      assert_raise SchemaError, msg, fn ->
        xema(:integer, multiple_of: "1")
      end
    end

    test "keyword multiple_of with too small value" do
      msg = ~s(multiple_of must be strictly greater than 0.)

      assert_raise SchemaError, msg, fn ->
        xema(:integer, multiple_of: 0)
      end
    end

    test "keyword enum with invalid entries" do
      msg = "Entries of enum have to be Integers."

      assert_raise SchemaError, msg, fn ->
        xema(:integer, enum: [1, "two"])
      end
    end
  end

  describe "schema type float:" do
    # unsupprted keyword

    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :float."

      assert_raise SchemaError, expected, fn ->
        xema(:float, foo: false)
      end
    end

    # Keyword: exclusive_maximum

    @tag :float
    @tag :exclusive_maximum
    test "keyword exclusive_maximum with a wrong type and undefined maximum" do
      expected = ~s(Expected a number for exclusive_maximum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_maximum: "1")
      end
    end

    @tag :float
    @tag :exclusive_maximum
    test "keyword exclusive_maximum with a wrong type and defined maximum" do
      expected = ~s(Expected a boolean for exclusive_maximum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_maximum: "1", maximum: 1)
      end
    end

    @tag :float
    @tag :exclusive_maximum
    test "keyword exclusive_maximum as boolean and undefined maximum" do
      expected = ~s(No maximum value found for exclusive_maximum.)

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_maximum: true)
      end
    end

    @tag :float
    @tag :exclusive_maximum
    test "keyword exclusive_maximum as number and defined maximum" do
      expected = ~s(The exclusive_maximum overwrites maximum.)

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_maximum: 1, maximum: 1)
      end
    end

    # Keyword: exclusive_minimum

    @tag :float
    @tag :exclusive_minimum
    test "keyword exclusive_minimum with a wrong type and undefined minimum" do
      expected = ~s(Expected a number for exclusive_minimum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_minimum: "1")
      end
    end

    @tag :float
    @tag :exclusive_minimum
    test "keyword exclusive_minimum with a wrong type and defined minimum" do
      expected = ~s(Expected a boolean for exclusive_minimum, got "1")

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_minimum: "1", minimum: 1)
      end
    end

    @tag :float
    @tag :exclusive_minimum
    test "keyword exclusive_minimum as boolean and undefined minimum" do
      expected = ~s(No minimum value found for exclusive_minimum.)

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_minimum: true)
      end
    end

    @tag :float
    @tag :exclusive_minimum
    test "keyword exclusive_minimum as number and defined minimum" do
      expected = ~s(The exclusive_minimum overwrites minimum.)

      assert_raise SchemaError, expected, fn ->
        xema(:float, exclusive_minimum: 1, minimum: 1)
      end
    end

    # Keyword: maximum

    test "keyword maximum with a wrong type" do
      expected = ~s(Expected a number for maximum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:float, maximum: "5")
      end
    end

    # Keyword: minimum

    test "keyword minimum with a wrong type" do
      expected = ~s(Expected a number for minimum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:float, minimum: "5")
      end

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{foo: {:float, minimum: "5"}})
      end
    end

    # Keyword: multiple_of

    test "keyword multiple_of with a wrong type" do
      msg = ~s(Expected a number for multiple_of, got "1".)

      assert_raise SchemaError, msg, fn ->
        xema(:float, multiple_of: "1")
      end
    end

    test "keyword multiple_of with too small value" do
      msg = ~s(multiple_of must be strictly greater than 0.)

      assert_raise SchemaError, msg, fn ->
        xema(:float, multiple_of: 0)
      end
    end

    # Keyword: enum

    test "keyword enum with invalid entries" do
      msg = "Entries of enum have to be Floats."

      assert_raise SchemaError, msg, fn ->
        xema(:float, enum: [1.0, "two"])
      end
    end
  end
end
