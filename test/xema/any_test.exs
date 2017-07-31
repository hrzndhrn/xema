defmodule Xema.AnyTest do

  use ExUnit.Case, async: true

  import Xema

  describe "schema 'any'" do
    setup do
      %{schema: xema(:any)}
    end

    test "type", %{schema: schema} do
      assert schema.type == :any
      assert type(schema) == :any
    end

    test "is_valid?/2 returns true for a string", %{schema: schema},
      do: assert is_valid?(schema, "foo")

    test "is_valid?/2 returns true for a number", %{schema: schema},
      do: assert is_valid?(schema, 42)

    test "is_valid?/2 returns true for nil", %{schema: schema},
      do: assert is_valid?(schema, nil)

    test "is_valid?/2 returns true for a list", %{schema: schema},
      do: assert is_valid?(schema, [1, 2, 3])

    test "validate/2 returns :ok for a string", %{schema: schema},
      do: assert validate(schema, "foo") == :ok

    test "validate/2 returns :ok for a number", %{schema: schema},
      do: assert validate(schema, 42) == :ok

    test "validate/2 returns :ok for nil", %{schema: schema},
      do: assert validate(schema, nil) == :ok

    test "validate/2 returns true for a list", %{schema: schema},
      do: assert validate(schema, [1, 2, 3]) == :ok
  end
end
