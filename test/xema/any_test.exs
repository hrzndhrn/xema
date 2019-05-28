defmodule Xema.AnyTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "'any' schema" do
    setup do
      %{schema: Xema.new(:any)}
    end

    test "valid?/2 with a string", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "valid?/2 with a number", %{schema: schema} do
      assert valid?(schema, 42)
    end

    test "valid?/2 with nil", %{schema: schema} do
      assert valid?(schema, nil)
    end

    test "valid?/2 with a list", %{schema: schema} do
      assert valid?(schema, [1, 2, 3])
    end

    test "validate/2 with a string", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end

    test "validate/2 with a number", %{schema: schema} do
      assert validate(schema, 42) == :ok
    end

    test "validate/2 with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "validate/2 with a list", %{schema: schema} do
      assert validate(schema, [1, 2, 3]) == :ok
    end
  end

  describe "'any' schema with enum:" do
    setup do
      %{
        schema: Xema.new({:any, enum: [1, 1.2, [1], "foo", :bar]})
      }
    end

    test "validate/2 with a value from the enum", %{schema: schema} do
      assert validate(schema, 1) == :ok
      assert validate(schema, 1.2) == :ok
      assert validate(schema, "foo") == :ok
      assert validate(schema, [1]) == :ok
      assert validate(schema, :bar) == :ok
    end

    test "validate/2 with a value that is not in the enum", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  value: 2,
                  enum: [1, 1.2, [1], "foo", :bar]
                }
              } = error} = validate(schema, 2)

      assert Exception.message(error) == "Value 2 is not defined in enum."
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, 1)
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute valid?(schema, 5)
    end
  end

  describe "'any' schema with enum (shortcut):" do
    setup do
      %{
        schema: Xema.new(enum: [1, 1.2, [1], "foo"])
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema == Xema.new({:any, enum: [1, 1.2, [1], "foo"]})
    end
  end

  describe "'any' schema with keyword minimum:" do
    setup do
      %{schema: Xema.new({:any, minimum: 2})}
    end

    test "equal shortcut", %{schema: schema} do
      assert schema == Xema.new(minimum: 2)
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 2) == :ok
      assert validate(schema, 3) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{minimum: 2, value: 0}
               } = error
             } = validate(schema, 0)

      assert Exception.message(error) == "Value 0 is less than minimum value of 2."
    end

    test "validate/2 ignore non-numbers", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end
  end

  describe "any-schema with keyword multiple_of:" do
    setup do
      %{schema: Xema.new({:any, multiple_of: 2})}
    end

    test "equal shortcut", %{schema: schema} do
      assert schema == Xema.new(multiple_of: 2)
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 2) == :ok
      assert validate(schema, 4) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{multiple_of: 2, value: 3}
               } = error
             } = validate(schema, 3)

      assert Exception.message(error) == "Value 3 is not a multiple of 2."
    end

    test "validate/2 ignore non-numbers", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end
  end

  describe "any-schema with keyword additional_items:" do
    setup do
      %{schema: Xema.new({:any, additional_items: false})}
    end

    test "validate/2 with a list", %{schema: schema} do
      assert validate(schema, [1, "2"]) == :ok
    end

    test "validate/2 with a map", %{schema: schema} do
      assert validate(schema, %{a: 1}) == :ok
    end
  end

  describe "dependencies with boolean subschemas:" do
    setup do
      %{
        schema:
          Xema.new({
            :any,
            dependencies: %{
              foo: true,
              bar: false
            }
          })
      }
    end

    test "map with property having schema true is valid", %{schema: schema} do
      assert validate(schema, %{foo: 1}) == :ok
    end

    test "object with property having schema false is invalid", %{schema: schema} do
      assert {
               :error,
               %ValidationError{reason: %{dependencies: %{bar: %{type: false}}}} = error
             } = validate(schema, %{bar: 2})

      message = """
      Dependencies for :bar failed.
        Schema always fails validation.\
      """

      assert Exception.message(error) == message
    end
  end
end
