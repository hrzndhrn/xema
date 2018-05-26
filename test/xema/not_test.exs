defmodule Xema.NotTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

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
      assert validate(schema, 1) == {:error, %{not: :ok, value: 1}}
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
               {:error, %{properties: %{foo: %{not: :ok, value: "foo"}}}}
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
end
