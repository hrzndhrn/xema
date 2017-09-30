defmodule Xema.BooleanTest do

  use ExUnit.Case, async: true

  import Xema

  describe "'boolean' schema" do
    setup do
      %{schema: xema(:boolean)}
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :boolean
    end

    test "is_valid?/2 with value true", %{schema: schema},
      do: assert is_valid?(schema, true)

    test "is_valid?/2 with value false", %{schema: schema},
      do: assert is_valid?(schema, false)

    test "is_valid?/2 with non boolean values", %{schema: schema} do
        refute is_valid?(schema, 1)
        refute is_valid?(schema, "1")
        refute is_valid?(schema, [1])
        refute is_valid?(schema, nil)
        refute is_valid?(schema, %{foo: "foo"})
    end

    test "validate/2 with value true", %{schema: schema},
      do: assert validate(schema, true) == :ok

    test "validate/2 with value false", %{schema: schema},
      do: assert validate(schema, false) == :ok

    test "validate/2 with non boolean value", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :boolean}}
      assert validate(schema, "true") == expected
      assert validate(schema, 1) == expected
      assert validate(schema, []) == expected
    end
  end
end
