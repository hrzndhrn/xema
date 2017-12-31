defmodule Xema.BoolLogicTest do
  use ExUnit.Case

  doctest Xema.Any

  import Xema

  describe "keyword not:" do
    setup do
      %{schema: xema(:any, not: :integer)}
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 1) == {:error, :not}
    end
  end

  describe "nested keyword not:" do
    setup do
      %{
        schema:
          xema(
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

  describe "keyword all_of:" do
    setup do
      %{
        schema:
          xema(
            :any,
            all_of: [:integer, {:integer, minimum: 0}]
          )
      }
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an imvalid value", %{schema: schema} do
      assert validate(schema, -1) == {:error, :all_of}
    end
  end

  describe "keyword any_of:" do
    setup do
      %{
        schema:
          xema(
            :any,
            any_of: [:nil, {:integer, minimum: 1}]
          )
      }
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
      assert validate(schema, nil) == :ok
    end

    test "validate/2 with an imvalid value", %{schema: schema} do
      assert validate(schema, "foo") == {:error, :any_of}
    end
  end
end
