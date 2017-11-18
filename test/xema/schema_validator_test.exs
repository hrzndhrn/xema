defmodule Xema.SchemaValidatorTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  import Xema

  describe "schema type number:" do
    test "keyword maximum with wrong value type" do
      expected = ~s(Expected an Integer or Float for maximum, got "5".)

      assert_raise SchemaError, expected, fn ->
        xema(:float, maximum: "5")
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

  describe "schema type integer" do
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

    test "keyword multiple_of with too small value" do
      msg = ~s(multiple_of must be strictly greater than 0.)

      assert_raise SchemaError, msg, fn ->
        xema(:integer, multiple_of: 0)
      end
    end
  end

  describe "schema type float" do
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
