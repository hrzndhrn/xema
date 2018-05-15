defmodule Xema.BooleanSchemaTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  describe "true schema:" do
    setup do
      %{schema: Xema.new(true)}
    end

    test "type", %{schema: schema} do
      assert schema.content.type == true
    end

    test "is_valid?/2 returns always true", %{schema: schema} do
      assert is_valid?(schema, true)
      assert is_valid?(schema, 42)
      assert is_valid?(schema, "foo")
      assert is_valid?(schema, [])
      assert is_valid?(schema, %{})
    end

    test "validate/2 returns always :ok", %{schema: schema} do
      assert(validate(schema, true) == :ok)
      assert(validate(schema, 42) == :ok)
      assert(validate(schema, "foo") == :ok)
      assert(validate(schema, []) == :ok)
      assert(validate(schema, %{}) == :ok)
    end
  end

  describe "false schema:" do
    setup do
      %{schema: Xema.new(false)}
    end

    test "type", %{schema: schema} do
      assert schema.content.type == false
    end

    test "is_valid?/2 returns always false", %{schema: schema} do
      refute is_valid?(schema, true)
      refute is_valid?(schema, 42)
      refute is_valid?(schema, "foo")
      refute is_valid?(schema, [])
      refute is_valid?(schema, %{})
    end

    test "validate/2 returns always {:error, %{type: false}}", %{schema: schema} do
      assert(validate(schema, true) == {:error, %{type: false}})
      assert(validate(schema, 42) == {:error, %{type: false}})
      assert(validate(schema, "foo") == {:error, %{type: false}})
      assert(validate(schema, []) == {:error, %{type: false}})
      assert(validate(schema, %{}) == {:error, %{type: false}})
    end
  end

  describe "all_of with boolean schemas, all true:" do
    setup do
      %{schema: Xema.new(:all_of, [true, true])}
    end

    test "is_valid?/2 returns always true", %{schema: schema} do
      assert is_valid?(schema, true)
      assert is_valid?(schema, 42)
      assert is_valid?(schema, "foo")
      assert is_valid?(schema, [])
      assert is_valid?(schema, %{})
    end
  end
end
