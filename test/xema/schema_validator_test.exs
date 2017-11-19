defmodule Xema.SchemaValidatorTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  import Xema

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
        xema(:list, items: [:string], additional_items: {:integer, minimum: "1"})
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
  end

  describe "schema type number:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :number."

      assert_raise SchemaError, expected, fn ->
        xema(:number, foo: false)
      end
    end

    test "keyword maximum with wrong value type" do
      expected = ~s(Expected an Integer or Float for maximum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:float, maximum: "5", minimum: 1)
      end
    end

    test "keyword minimum with wrong value type" do
      expected = ~s(Expected an Integer or Float for minimum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:number, minimum: "5")
      end

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{foo: {:number, minimum: "5"}})
      end
    end

    test "keyword multiple_of with wrong value type" do
      msg = ~s(Expected an Integer or Float for multiple_of, got "1".)

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
  end

  describe "schema type integer:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :integer."

      assert_raise SchemaError, expected, fn ->
        xema(:integer, foo: false)
      end
    end

    test "keyword maximum with wrong value type" do
      expected = ~s(Expected an Integer for maximum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, maximum: "5")
      end
    end

    test "keyword minimum with wrong value type" do
      expected = ~s(Expected an Integer for minimum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:integer, minimum: "5")
      end

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{foo: {:integer, minimum: "5"}})
      end
    end

    test "keyword multiple_of with wrong value type" do
      msg = ~s(Expected an Integer for multiple_of, got "1".)

      assert_raise SchemaError, msg, fn ->
        xema(:integer, multiple_of: "1")
      end
    end

    @tag :only
    test "keyword multiple_of with too small value" do
      msg = ~s(multiple_of must be strictly greater than 0.)

      assert_raise SchemaError, msg, fn ->
        xema(:integer, multiple_of: 0)
      end
    end
  end

  describe "schema type float:" do
    test "unsupported keyword" do
      expected = "Keywords [:foo] are not supported by :float."

      assert_raise SchemaError, expected, fn ->
        xema(:float, foo: false)
      end
    end

    test "keyword maximum with wrong value type" do
      expected = ~s(Expected an Integer or Float for maximum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:float, maximum: "5")
      end
    end

    test "keyword minimum with wrong value type" do
      expected = ~s(Expected an Integer or Float for minimum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:float, minimum: "5")
      end

      assert_raise SchemaError, expected, fn ->
        xema(:map, properties: %{foo: {:float, minimum: "5"}})
      end
    end

    test "keyword multiple_of with wrong value type" do
      msg = ~s(Expected an Integer or Float for multiple_of, got "1".)

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
  end
end
