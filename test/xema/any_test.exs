defmodule Xema.AnyTest do
  use ExUnit.Case

  # doctest Xema.Any

  import Xema

  describe "'any' schema" do
    setup do
      %{schema: xema(:any)}
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :any
    end

    test "is_valid?/2 with a string", %{schema: schema},
      do: assert is_valid?(schema, "foo")

    test "is_valid?/2 with a number", %{schema: schema},
      do: assert is_valid?(schema, 42)

    test "is_valid?/2 with nil", %{schema: schema},
      do: assert is_valid?(schema, nil)

    test "is_valid?/2 with a list", %{schema: schema},
      do: assert is_valid?(schema, [1, 2, 3])

    test "validate/2 with a string", %{schema: schema},
      do: assert validate(schema, "foo") == :ok

    test "validate/2 with a number", %{schema: schema},
      do: assert validate(schema, 42) == :ok

    test "validate/2 with nil", %{schema: schema},
      do: assert validate(schema, nil) == :ok

    test "validate/2 with a list", %{schema: schema},
      do: assert validate(schema, [1, 2, 3]) == :ok
  end

  describe "'any' schema with enum" do
    setup do
      %{
        schema: xema(:any, enum: [1, 1.2, [1], "foo"])
      }
    end

    test "with a value from the enum", %{schema: schema} do
      assert validate(schema, 1) == :ok
      assert validate(schema, 1.2) == :ok
      assert validate(schema, "foo") == :ok
      assert validate(schema, [1]) == :ok
    end

    test "with a value that is not in the enum", %{schema: schema} do
      expected = %{
        reason: :not_in_enum,
        enum: [1, 1.2, [1], "foo"],
        element: nil
      }
      assert validate(schema, 2) == {:error, %{expected | element: 2}}
      assert validate(schema, 2.2) == {:error, %{expected | element: 2.2}}
      assert validate(schema, "bar") == {:error, %{expected | element: "bar"}}
      assert validate(schema, [2]) == {:error, %{expected | element: [2]}}
    end

    test "is_valid?/2 with a valid value", %{schema: schema},
      do: assert is_valid?(schema, 1)

    test "is_valid?/2 with an invalid value", %{schema: schema},
      do: refute is_valid?(schema, 5)
  end
end
