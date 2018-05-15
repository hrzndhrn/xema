defmodule Xema.BooleanTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  describe "'boolean' schema" do
    setup do
      %{schema: Xema.new(:boolean)}
    end

    test "type", %{schema: schema} do
      assert schema.content.type == :boolean
    end

    test "is_valid?/2 with value true", %{schema: schema} do
      assert is_valid?(schema, true)
    end

    test "is_valid?/2 with value false", %{schema: schema} do
      assert is_valid?(schema, false)
    end

    test "is_valid?/2 with non boolean values", %{schema: schema} do
      refute is_valid?(schema, 1)
      refute is_valid?(schema, "1")
      refute is_valid?(schema, [1])
      refute is_valid?(schema, nil)
      refute is_valid?(schema, %{foo: "foo"})
    end

    test "validate/2 with value true", %{schema: schema} do
      assert(validate(schema, true) == :ok)
    end

    test "validate/2 with value false", %{schema: schema} do
      assert(validate(schema, false) == :ok)
    end

    test "validate/2 with non boolean value", %{schema: schema} do
      expected = {:error, %{type: :boolean, value: "true"}}

      assert validate(schema, "true") == expected
    end
  end
end
