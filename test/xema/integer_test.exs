defmodule Xema.IntegerTest do
  use ExUnit.Case, async: true

  import Xema

  describe "'integer' schema" do
    setup do
      %{schema: xema(:integer)}
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :integer
    end

    test "validate/2 with an integer", %{schema: schema} do
      assert validate(schema, 2) == :ok
    end

    test "validate/2 with a float", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :integer}}
      assert validate(schema, 2.3) == expected
    end

    test "validate/2 with a string", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :integer}}
      assert validate(schema, "foo") == expected
    end

    test "is_valid?/2 with a valid value", %{schema: schema} do
      assert is_valid?(schema, 5)
    end

    test "is_valid?/2 with an invalid value", %{schema: schema} do
      refute(is_valid?(schema, [1]))
    end
  end

  describe "'integer' schema with range" do
    setup do
      %{schema: xema(:integer, minimum: 2, maximum: 4)}
    end

    test "validate/2 with a integer in range", %{schema: schema} do
      assert validate(schema, 2) == :ok
      assert validate(schema, 3) == :ok
      assert validate(schema, 4) == :ok
    end

    test "validate/2 with a too small integer", %{schema: schema} do
      expected = {:error, %{minimum: 2, reason: :too_small}}
      assert validate(schema, 1) == expected
    end

    test "validate/2 with a too big integer", %{schema: schema} do
      expected = {:error, %{maximum: 4, reason: :too_big}}
      assert validate(schema, 5) == expected
    end
  end

  describe "'integer' schema with exclusive range" do
    setup do
      %{
        schema:
          xema(
            :integer,
            minimum: 2,
            maximum: 4,
            exclusive_minimum: true,
            exclusive_maximum: true
          )
      }
    end

    test "validate/2 with a integer in range", %{schema: schema} do
      assert(validate(schema, 3) == :ok)
    end

    test "validate/2 with a too small integer", %{schema: schema} do
      expected = {:error, %{minimum: 2, reason: :too_small}}
      assert validate(schema, 1) == expected
    end

    test "validate/2 with a minimum integer", %{schema: schema} do
      expected =
        {
          :error,
          %{minimum: 2, reason: :too_small, exclusive_minimum: true}
        }

      assert validate(schema, 2) == expected
    end

    test "validate/2 with a maximum integer", %{schema: schema} do
      expected =
        {
          :error,
          %{maximum: 4, reason: :too_big, exclusive_maximum: true}
        }

      assert validate(schema, 4) == expected
    end

    test "validate/2 with a too big integer", %{schema: schema} do
      expected = {:error, %{maximum: 4, reason: :too_big}}
      assert validate(schema, 5) == expected
    end
  end

  describe "'integer' schema with multiple-of" do
    setup do
      %{schema: xema(:integer, multiple_of: 2)}
    end

    test "validate/2 with a valid integer", %{schema: schema} do
      assert(validate(schema, 6) == :ok)
    end

    test "validate/2 with an invalid integer", %{schema: schema} do
      expected = {:error, %{reason: :not_multiple, multiple_of: 2}}
      assert validate(schema, 7) == expected
    end
  end

  describe "'integer' schema with enum" do
    setup do
      %{schema: xema(:integer, enum: [1, 3])}
    end

    test "with a value from the enum", %{schema: schema} do
      assert validate(schema, 3) == :ok
    end

    test "with a value that is not in the enum", %{schema: schema} do
      expected =
        {:error, %{
          reason: :not_in_enum,
          enum: [1, 3],
          element: 2
        }}

      assert validate(schema, 2) == expected
    end
  end
end
