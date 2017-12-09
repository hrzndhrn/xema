defmodule Xema.FloatTest do
  use ExUnit.Case, async: true

  doctest Xema.Float

  import Xema

  describe "'float' schema" do
    setup do
      %{schema: xema(:float)}
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :float
    end

    test "validate/2 with a float", %{schema: schema} do
      assert validate(schema, 2.3) == :ok
    end

    test "validate/2 with an integer", %{schema: schema} do
      expected =
        {:error, %Xema.TypeError{
          type: :float,
          value: 2,
          message: ~s(Expected :float, got 2.)
        }}

      assert validate(schema, 2) == expected
    end

    test "validate/2 with a string", %{schema: schema} do
      expected =
        {:error, %Xema.TypeError{
          type: :float,
          value: "foo",
          message: ~s(Expected :float, got "foo".)
        }}

      assert validate(schema, "foo") == expected
    end

    test "is_valid?/2 with a valid value", %{schema: schema} do
      assert is_valid?(schema, 5.6)
    end

    test "is_valid?/2 with an invalid value", %{schema: schema} do
      refute(is_valid?(schema, [1]))
    end
  end

  describe "'float' schema with range" do
    setup do
      %{schema: xema(:float, minimum: 2, maximum: 4)}
    end

    test "validate/2 with a float in range", %{schema: schema} do
      assert validate(schema, 2.0) == :ok
      assert validate(schema, 3.0) == :ok
      assert validate(schema, 4.0) == :ok
    end

    test "validate/2 with a too small float", %{schema: schema} do
      expected = {:error, %{minimum: 2, reason: :too_small}}
      assert validate(schema, 1.0) == expected
    end

    test "validate/2 with a too big float", %{schema: schema} do
      expected = {:error, %Xema.RangeError{
        value: 5.0,
        maximum: 4,
        message: "Expected a value with a maximum of 4, got 5.0."
      }}

      assert validate(schema, 5.0) == expected
    end
  end

  describe "'float' schema with exclusive range" do
    setup do
      %{
        schema:
          xema(
            :float,
            minimum: 2,
            maximum: 4,
            exclusive_minimum: true,
            exclusive_maximum: true
          )
      }
    end

    test "validate/2 with a float in range", %{schema: schema} do
      assert(validate(schema, 3.0) == :ok)
    end

    test "validate/2 with a too small float", %{schema: schema} do
      expected = {:error, %{minimum: 2, reason: :too_small}}
      assert validate(schema, 1.0) == expected
    end

    test "validate/2 with a minimum float", %{schema: schema} do
      expected =
        {
          :error,
          %{minimum: 2, reason: :too_small, exclusive_minimum: true}
        }

      assert validate(schema, 2.0) == expected
    end

    test "validate/2 with a maximum float", %{schema: schema} do
      expected = {:error, %Xema.RangeError{
        value: 4.0,
        maximum: 4,
        exclusive_maximum: true,
        message: "Expected a value with an exclusive maximum of 4, got 4.0."
      }}

      assert validate(schema, 4.0) == expected
    end

    test "validate/2 with a too big float", %{schema: schema} do
      expected = {:error, %Xema.RangeError{
        value: 5.0,
        maximum: 4,
        exclusive_maximum: true,
        message: "Expected a value with an exclusive maximum of 4, got 5.0."
      }}

      assert validate(schema, 5.0) == expected
    end
  end

  describe "'float' schema with multiple-of" do
    setup do
      %{schema: xema(:float, multiple_of: 1.2)}
    end

    test "validate/2 with a valid float", %{schema: schema} do
      assert(validate(schema, 3.6) == :ok)
    end

    test "validate/2 with an invalid float", %{schema: schema} do
      expected = {:error, %{reason: :not_multiple, multiple_of: 1.2}}
      assert validate(schema, 6.2) == expected
    end
  end

  describe "'float' schema with enum" do
    setup do
      %{schema: xema(:float, enum: [1.2, 1.3, 3.3])}
    end

    test "with a value from the enum", %{schema: schema} do
      assert(validate(schema, 1.3) == :ok)
    end

    test "with a value that is not in the enum", %{schema: schema} do
      expected =
        {:error, %Xema.EnumError{
          message: "Value 2.2 is not in enum [1.2, 1.3, 3.3].",
          enum: [1.2, 1.3, 3.3],
          value: 2.2
        }}

      assert validate(schema, 2.2) == expected
    end
  end
end
