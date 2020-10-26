defmodule Xema.NotTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "keyword not:" do
    setup do
      %{schema: Xema.new({:any, not: :integer})}
    end

    test "type", %{schema: schema} do
      assert schema.schema.type == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{not: :ok, value: 1}
               } = error
             } = validate(schema, 1)

      assert Exception.message(error) == "Value is valid against schema from not, got 1."
    end
  end

  describe "not with boolean schema true" do
    setup do
      %{
        schema: Xema.new(not: true)
      }
    end

    test "any value is valid", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{not: :ok, value: 19}
               } = error
             } = validate(schema, 19)

      assert Exception.message(error) == "Value is valid against schema from not, got 19."
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
          Xema.new({
            :map,
            properties: %{
              foo: {:any, not: {:string, min_length: 3}}
            }
          })
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, %{foo: ""}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{properties: %{foo: %{not: :ok, value: "foo"}}}
               } = error
             } = validate(schema, %{foo: "foo"})

      assert Exception.message(error) ==
               ~s|Value is valid against schema from not, got "foo", at [:foo].|
    end
  end

  describe "nested keyword not (shortcut):" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              foo: [not: {:string, min_length: 4}]
            }
          })
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema ==
               Xema.new({
                 :map,
                 properties: %{
                   foo: {:any, not: {:string, min_length: 4}}
                 }
               })
    end

    test "validates strings", %{schema: schema} do
      assert Xema.valid?(schema, %{foo: "abc"})
      refute Xema.valid?(schema, %{foo: "abcdef"})
    end

    test "alternative schema", %{schema: schema} do
      alt =
        Xema.new({
          :map,
          properties: %{
            foo: {:string, not: [min_length: 4]}
          }
        })

      assert schema != alt

      assert Xema.valid?(schema, %{foo: "abc"})
      refute Xema.valid?(schema, %{foo: "abcdef"})

      assert Xema.valid?(alt, %{foo: "abc"})
      refute Xema.valid?(alt, %{foo: "abcdef"})
    end
  end
end
