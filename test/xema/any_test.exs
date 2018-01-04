defmodule Xema.AnyTest do
  use ExUnit.Case

  import Xema, only: [is_valid?: 2, validate: 2]

  describe "'any' schema" do
    setup do
      %{schema: Xema.new(:any)}
    end

    test "type", %{schema: schema} do
      assert schema.content.as == :any
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
      assert schema.content.as == :any
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

    test "type", %{schema: schema} do
      assert schema.content.as == :any
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
      assert validate(schema, %{foo: "foo"}) == {:error, %{foo: :not}}
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

  describe "keyword all_of:" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            all_of: [:integer, {:integer, minimum: 0}]
          )
      }
    end

    test "type", %{schema: schema} do
      assert schema.content.as == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an imvalid value", %{schema: schema} do
      assert validate(schema, -1) == {:error, :all_of}
    end
  end

  describe "keyword all_of (shortcut):" do
    setup do
      %{
        schema: Xema.new(:all_of, [:integer, {:integer, minimum: 0}])
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema ==
               Xema.new(
                 :any,
                 all_of: [:integer, {:integer, minimum: 0}]
               )
    end
  end

  describe "keyword any_of:" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            any_of: [nil, {:integer, minimum: 1}]
          )
      }
    end

    test "type", %{schema: schema} do
      assert schema.content.as == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
      assert validate(schema, nil) == :ok
    end

    test "validate/2 with an imvalid value", %{schema: schema} do
      assert validate(schema, "foo") == {:error, :any_of}
    end
  end

  describe "keyword any_of (shortcut):" do
    setup do
      %{
        schema: Xema.new(:any_of, [nil, {:integer, minimum: 1}])
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema ==
               Xema.new(
                 :any,
                 any_of: [nil, {:integer, minimum: 1}]
               )
    end
  end

  describe "keyword one_of (multiple_of):" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            one_of: [{:integer, multiple_of: 3}, {:integer, multiple_of: 5}]
          )
      }
    end

    test "type", %{schema: schema} do
      assert schema.content.as == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 9) == :ok
      assert validate(schema, 10) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 15) == {:error, :one_of}
      assert validate(schema, 4) == {:error, :one_of}
    end
  end

  describe "keyword one_of (multiple_of integer):" do
    setup do
      %{
        schema:
          Xema.new(
            :integer,
            one_of: [
              %{multiple_of: 3},
              %{multiple_of: 5}
            ]
          )
      }
    end

    test "type", %{schema: schema} do
      assert schema.content.as == :integer
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 9) == :ok
      assert validate(schema, 10) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 15) == {:error, :one_of}
      assert validate(schema, 4) == {:error, :one_of}
    end
  end

  describe "keyword one_of (shortcut):" do
    setup do
      %{
        schema: Xema.new(:one_of, [{:integer, multiple_of: 3}, {:integer, multiple_of: 5}])
      }
    end

    test "type", %{schema: schema} do
      assert schema ==
               Xema.new(
                 :any,
                 one_of: [{:integer, multiple_of: 3}, {:integer, multiple_of: 5}]
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
end
