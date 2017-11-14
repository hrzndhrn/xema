defmodule Xema.SchemaValidatorTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  import Xema

  describe "schema type integer" do
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

  test "keyword multiple_of with wrong value" do
    msg = ~s(Expected a Float or Integer for multiple_of, got "1".)

    assert_raise SchemaError, msg, fn ->
      xema(:number, multiple_of: "1")
    end

    msg = ~s(Expected a Float or Integer for multiple_of, got "1".)

    assert_raise SchemaError, msg, fn ->
      xema(:float, multiple_of: "1")
    end

    msg = ~s(multiple_of must be strictly greater than 0.)

    assert_raise SchemaError, msg, fn ->
      xema(:number, multiple_of: -10)
    end

    msg = ~s(multiple_of must be strictly greater than 0.)

    assert_raise SchemaError, msg, fn ->
      xema(:float, multiple_of: 0)
    end
  end
end
