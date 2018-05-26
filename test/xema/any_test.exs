defmodule Xema.AnyTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  describe "'any' schema" do
    setup do
      %{schema: Xema.new(:any)}
    end

    test "is_valid?/2 with a string", %{schema: schema} do
      assert is_valid?(schema, "foo")
    end

    test "is_valid?/2 with a number", %{schema: schema} do
      assert is_valid?(schema, 42)
    end

    test "is_valid?/2 with nil", %{schema: schema} do
      assert is_valid?(schema, nil)
    end

    test "is_valid?/2 with a list", %{schema: schema} do
      assert is_valid?(schema, [1, 2, 3])
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
        schema: Xema.new(:any, enum: [1, 1.2, [1], "foo"])
      }
    end

    test "validate/2 with a value from the enum", %{schema: schema} do
      assert validate(schema, 1) == :ok
      assert validate(schema, 1.2) == :ok
      assert validate(schema, "foo") == :ok
      assert validate(schema, [1]) == :ok
    end

    test "validate/2 with a value that is not in the enum", %{schema: schema} do
      expected = {:error, %{value: 2, enum: [1, 1.2, [1], "foo"]}}

      assert validate(schema, 2) == expected
    end

    test "is_valid?/2 with a valid value", %{schema: schema} do
      assert is_valid?(schema, 1)
    end

    test "is_valid?/2 with an invalid value", %{schema: schema} do
      refute is_valid?(schema, 5)
    end
  end

  describe "'any' schema with enum (shortcut):" do
    setup do
      %{
        schema: Xema.new(:enum, [1, 1.2, [1], "foo"])
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema == Xema.new(:any, enum: [1, 1.2, [1], "foo"])
    end
  end

  describe "keyword not:" do
    setup do
      %{schema: Xema.new(:any, not: :integer)}
    end

    test "type", %{schema: schema} do
      assert schema.content.type == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 1) == {:error, :not}
    end
  end

  describe "keyword not (shortcut):" do
    setup do
      %{schema: Xema.new(:not, :integer)}
    end

    test "equal long version", %{schema: schema} do
      assert schema == Xema.new(:any, not: :integer)
    end
  end

  describe "nested keyword not:" do
    setup do
      %{
        schema:
          Xema.new(
            :map,
            properties: %{
              foo: {:any, not: {:string, min_length: 3}}
            }
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, %{foo: ""}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, %{foo: "foo"}) ==
               {:error, %{properties: %{foo: :not}}}
    end
  end

  describe "nested keyword not (shortcut):" do
    setup do
      %{
        schema:
          Xema.new(
            :map,
            properties: %{
              foo: {:not, {:string, min_length: 3}}
            }
          )
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema ==
               Xema.new(
                 :map,
                 properties: %{
                   foo: {:any, not: {:string, min_length: 3}}
                 }
               )
    end
  end

  describe "'any' schema with keyword minimum:" do
    setup do
      %{schema: Xema.new(:any, minimum: 2)}
    end

    test "equal shortcut", %{schema: schema} do
      assert schema == Xema.new(:minimum, 2)
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 2) == :ok
      assert validate(schema, 3) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 0) == {:error, %{minimum: 2, value: 0}}
    end

    test "validate/2 ignore non-numbers", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end
  end

  describe "any-schema with keyword multiple_of:" do
    setup do
      %{schema: Xema.new(:any, multiple_of: 2)}
    end

    test "equal shortcut", %{schema: schema} do
      assert schema == Xema.new(:multiple_of, 2)
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 2) == :ok
      assert validate(schema, 4) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 3) == {:error, %{multiple_of: 2, value: 3}}
    end

    test "validate/2 ignore non-numbers", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end
  end

  describe "any-schema with keyword additional_items:" do
    setup do
      %{schema: Xema.new(:any, additional_items: false)}
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
          Xema.new(
            :any,
            dependencies: %{
              foo: true,
              bar: false
            }
          )
      }
    end

    test "map with property having schema true is valid", %{schema: schema} do
      assert validate(schema, %{foo: 1}) == :ok
    end

    test """
         object with property having schema false is invalid
         """,
         %{schema: schema} do
      assert validate(schema, %{bar: 2}) ==
               {:error, %{dependencies: %{bar: %{type: false}}}}
    end
  end
end
