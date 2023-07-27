defmodule Xema.StructuringTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "structuring schema without definitions and ref" do
    setup do
      positive = Xema.new({:integer, minimum: 1})
      negative = Xema.new({:integer, maximum: -1})

      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              a: positive,
              b: positive,
              c: negative
            }
          })
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      assert validate(schema, %{a: 1, b: 2, c: -3}) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   properties: %{
                     a: %{minimum: 1, value: -1},
                     b: %{minimum: 1, value: -2},
                     c: %{maximum: -1, value: 3}
                   }
                 }
               } = error
             } = validate(schema, %{a: -1, b: -2, c: 3})

      assert message = Exception.message(error)
      assert message =~ ~s|Value -1 is less than minimum value of 1, at [:a].|
      assert message =~ ~s|Value -2 is less than minimum value of 1, at [:b].|
      assert message =~ ~s|Value 3 exceeds maximum value of -1, at [:c].|
    end
  end
end
