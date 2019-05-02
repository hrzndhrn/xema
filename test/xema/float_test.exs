defmodule Xema.FloatTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "'float' schema" do
    setup do
      %{schema: Xema.new(:float)}
    end

    test "validate/2 with a float", %{schema: schema} do
      assert validate(schema, 2.3) == :ok
    end

    test "validate/2 with an integer", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected :float, got 2.",
                 reason: %{type: :float, value: 2}
               }
             } = validate(schema, 2)
    end

    test "validate/2 with a string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected :float, got "foo".|,
                 reason: %{type: :float, value: "foo"}
               }
             } = validate(schema, "foo")
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, 5.6)
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute(valid?(schema, [1]))
    end
  end

  describe "'float' schema with range" do
    setup do
      %{schema: Xema.new({:float, minimum: 2, maximum: 4})}
    end

    test "validate/2 with a float in range", %{schema: schema} do
      assert validate(schema, 2.0) == :ok
      assert validate(schema, 3.0) == :ok
      assert validate(schema, 4.0) == :ok
    end

    test "validate/2 with a too small float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 1.0 is less than minimum value of 2.",
                 reason: %{value: 1.0, minimum: 2}
               }
             } = validate(schema, 1.0)
    end

    test "validate/2 with a too big float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 5.0 exceeds maximum value of 4.",
                 reason: %{value: 5.0, maximum: 4}
               }
             } = validate(schema, 5.0)
    end
  end

  describe "'float' schema with exclusive range (draft 04)" do
    setup do
      %{
        schema:
          Xema.new({
            :float,
            minimum: 2, maximum: 4, exclusive_minimum: true, exclusive_maximum: true
          })
      }
    end

    test "validate/2 with a float in range", %{schema: schema} do
      assert(validate(schema, 3.0) == :ok)
    end

    test "validate/2 with a too small float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 1.0 is less than minimum value of 2.",
                 reason: %{value: 1.0, minimum: 2, exclusive_minimum: true}
               }
             } = validate(schema, 1.0)
    end

    test "validate/2 with a minimum float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 2.0 equals exclusive minimum value of 2.",
                 reason: %{value: 2.0, minimum: 2, exclusive_minimum: true}
               }
             } = validate(schema, 2.0)
    end

    test "validate/2 with a maximum float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 4.0 equals exclusive maximum value of 4.",
                 reason: %{value: 4.0, maximum: 4, exclusive_maximum: true}
               }
             } = validate(schema, 4.0)
    end

    test "validate/2 with a too big float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 5.0 exceeds maximum value of 4.",
                 reason: %{value: 5.0, maximum: 4, exclusive_maximum: true}
               }
             } = validate(schema, 5.0)
    end
  end

  describe "'float' schema with exclusive range" do
    setup do
      %{
        schema:
          Xema.new({
            :float,
            exclusive_minimum: 1.2, exclusive_maximum: 1.4
          })
      }
    end

    test "validate/2 with a float in range", %{schema: schema} do
      assert validate(schema, 1.3) == :ok
    end

    test "validate/2 with a float equal to exclusive minimum", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 1.2 equals exclusive minimum value of 1.2.",
                 reason: %{exclusive_minimum: 1.2, value: 1.2}
               }
             } = validate(schema, 1.2)
    end

    test "validate/2 with a float equal to exclusive maximum", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 1.4 equals exclusive maximum value of 1.4.",
                 reason: %{exclusive_maximum: 1.4, value: 1.4}
               }
             } = validate(schema, 1.4)
    end
  end

  describe "'float' schema with multiple-of" do
    setup do
      %{schema: Xema.new({:float, multiple_of: 1.2})}
    end

    test "validate/2 with a valid float", %{schema: schema} do
      assert(validate(schema, 3.6) == :ok)
    end

    test "validate/2 with an invalid float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 6.2 is not a multiple of 1.2.",
                 reason: %{value: 6.2, multiple_of: 1.2}
               }
             } = validate(schema, 6.2)
    end
  end

  describe "'float' schema with enum" do
    setup do
      %{schema: Xema.new({:float, enum: [1.2, 1.3, 3.3]})}
    end

    test "with a value from the enum", %{schema: schema} do
      assert(validate(schema, 1.3) == :ok)
    end

    test "with a value that is not in the enum", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Value 2.2 is not defined in enum.",
                 reason: %{enum: [1.2, 1.3, 3.3], value: 2.2}
               }
             } = validate(schema, 2.2)
    end
  end
end
