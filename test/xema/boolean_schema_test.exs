defmodule Xema.BooleanSchemaTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "true schema:" do
    setup do
      %{schema: Xema.new(true)}
    end

    test "type", %{schema: schema} do
      assert schema.schema.type == true
    end

    test "valid?/2 returns always true", %{schema: schema} do
      assert valid?(schema, true)
      assert valid?(schema, 42)
      assert valid?(schema, "foo")
      assert valid?(schema, [])
      assert valid?(schema, %{})
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
      assert schema.schema.type == false
    end

    test "valid?/2 returns always false", %{schema: schema} do
      refute valid?(schema, true)
      refute valid?(schema, 42)
      refute valid?(schema, "foo")
      refute valid?(schema, [])
      refute valid?(schema, %{})
    end

    test "validate/2 returns always {:error, %{type: false}}", %{schema: schema} do
      assert {:error,
              %ValidationError{message: "Schema always fails validation.", reason: %{type: false}}} =
               validate(schema, true)

      assert {:error,
              %ValidationError{message: "Schema always fails validation.", reason: %{type: false}}} =
               validate(schema, 42)

      assert {:error,
              %ValidationError{message: "Schema always fails validation.", reason: %{type: false}}} =
               validate(schema, "true")

      assert {:error,
              %ValidationError{message: "Schema always fails validation.", reason: %{type: false}}} =
               validate(schema, [])

      assert {:error,
              %ValidationError{message: "Schema always fails validation.", reason: %{type: false}}} =
               validate(schema, %{})
    end
  end

  describe "all_of with boolean schemas, all true:" do
    setup do
      %{schema: Xema.new(all_of: [true, true])}
    end

    test "valid?/2 returns always true", %{schema: schema} do
      assert valid?(schema, true)
      assert valid?(schema, 42)
      assert valid?(schema, "foo")
      assert valid?(schema, [])
      assert valid?(schema, %{})
    end
  end
end
