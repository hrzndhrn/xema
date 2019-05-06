defmodule Xema.BooleanTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "'boolean' schema" do
    setup do
      %{schema: Xema.new(:boolean)}
    end

    test "type", %{schema: schema} do
      assert schema.schema.type == :boolean
    end

    test "valid?/2 with value true", %{schema: schema} do
      assert valid?(schema, true)
    end

    test "valid?/2 with value false", %{schema: schema} do
      assert valid?(schema, false)
    end

    test "valid?/2 with non boolean values", %{schema: schema} do
      refute valid?(schema, 1)
      refute valid?(schema, "1")
      refute valid?(schema, [1])
      refute valid?(schema, nil)
      refute valid?(schema, %{foo: "foo"})
    end

    test "validate/2 with value true", %{schema: schema} do
      assert(validate(schema, true) == :ok)
    end

    test "validate/2 with value false", %{schema: schema} do
      assert(validate(schema, false) == :ok)
    end

    test "validate/2 with non boolean value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected :boolean, got "true".|,
                 reason: %{type: :boolean, value: "true"}
               }
             } = validate(schema, "true")
    end
  end
end
