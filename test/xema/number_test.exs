defmodule Xema.NumberTest do

  use ExUnit.Case, async: true

  import Xema

  describe "'number' schema" do
    setup do
      %{schema: xema(:number)}
    end

    test "type", %{schema: schema} do
      assert schema.type == :number
      assert type(schema) == :number
    end

    test "validate/2 with a float", %{schema: schema},
      do: assert validate(schema, 2.3) == :ok

    test "validate/2 with an integer", %{schema: schema} do
      assert validate(schema, 2) == :ok
    end

    test "validate/2 with a string", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :number}}
      assert validate(schema, "foo") == expected
    end

    test "is_valid?/2 with a valid value", %{schema: schema},
      do: assert is_valid?(schema, 5.6)

    test "is_valid?/2 with an invalid value", %{schema: schema},
      do: refute is_valid?(schema, [1])
  end

  describe "'number' schema with range" do
    setup do
      %{schema: xema(:number, minimum: 2, maximum: 4)}
    end

    test "validate/2 with a number in range", %{schema: schema} do
      assert validate(schema, 2.0) == :ok
      assert validate(schema, 3.0) == :ok
      assert validate(schema, 4.0) == :ok
    end

    test "validate/2 with a too small number", %{schema: schema} do
      expected = {:error, %{minimum: 2, reason: :too_small}}
      assert validate(schema, 1.0) == expected
    end

    test "validate/2 with a too big number", %{schema: schema} do
      expected = {:error, %{maximum: 4, reason: :too_big}}
      assert validate(schema, 5.0) == expected
    end
  end

  describe "'number' schema with exclusive range" do
    setup do
      %{schema: xema(
          :number,
          minimum: 2,
          maximum: 4,
          exclusive_minimum: true,
          exclusive_maximum: true
      )}
    end

    test "validate/2 with a number in range", %{schema: schema},
      do: assert validate(schema, 3.0) == :ok

    test "validate/2 with a too small number", %{schema: schema} do
      expected = {:error,
        %{minimum: 2, reason: :too_small}}
      assert validate(schema, 1.0) == expected
    end

    test "validate/2 with a minimum number", %{schema: schema} do
      expected = {:error,
        %{minimum: 2, reason: :too_small, exclusive_minimum: true}}
      assert validate(schema, 2.0) == expected
    end

    test "validate/2 with a maximum number", %{schema: schema} do
      expected = {:error,
        %{maximum: 4, reason: :too_big, exclusive_maximum: true}}
      assert validate(schema, 4.0) == expected
    end

    test "validate/2 with a too big number", %{schema: schema} do
      expected = {:error,
        %{maximum: 4, reason: :too_big}}
      assert validate(schema, 5.0) == expected
    end
  end

  describe "'number' schema with multiple-of" do
    setup do
      %{schema: xema(:number, multiple_of: 1.2)}
    end

    test "validate/2 with a valid number", %{schema: schema},
      do: assert validate(schema, 3.6) == :ok

    test "validate/2 with an invalid number", %{schema: schema} do
      expected = {:error, %{reason: :not_multiple, multiple_of: 1.2}}
      assert validate(schema, 6.2) == expected
    end
  end

  describe "'number' schema with enum" do
    setup do
      %{schema: xema(:number, enum: [1.2, 1.3, 3.3])}
    end

    test "with a value from the enum", %{schema: schema},
      do: assert validate(schema, 1.3) == :ok

    test "with a value that is not in the enum", %{schema: schema} do
      expected = {:error, %{enum: [1.2, 1.3, 3.3], reason: :not_in_enum}}
      assert validate(schema, 2) == expected
    end
  end
end
