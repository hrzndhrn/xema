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

  describe "shortcut for keyword not" do
    setup do
      %{
        short: Xema.new(:not, :integer),
        key: Xema.new(not: :integer)
      }
    end

    test "equal to the long version", %{short: short, key: key} do
      assert short == Xema.new(:any, not: :integer)
      assert key == Xema.new(:any, not: :integer)
    end
  end

  describe "not with boolean schema true" do
    setup do
      %{
        schema: Xema.new(not: true)
      }
    end

    test "any value is valid", %{schema: schema} do
      assert validate(schema, 19) == {:error, %{not: :ok, value: 19}}
    end
  end

  describe "not with boolean schema false" do
    setup do
      %{
        schema: Xema.new(not: false)
      }
    end

    test "any value is invalid", %{schema: schema} do
      assert validate(schema, 19) == :ok
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
