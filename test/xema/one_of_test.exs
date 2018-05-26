defmodule Xema.OneOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

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

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 9) == :ok
      assert validate(schema, 10) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 15) == {:error, %{one_of: [], value: 15}}

      assert validate(schema, 4) ==
               {:error,
                %{one_of: [%{multiple_of: 5}, %{multiple_of: 3}], value: 4}}
    end
  end

  describe "keyword one_of (multiple_of integer):" do
    setup do
      %{
        schema:
          Xema.new(
            :integer,
            one_of: [
              {:multiple_of, 3},
              {:multiple_of, 5}
            ]
          )
      }
    end

    test "alternative notation", %{schema: schema} do
      alternative =
        Xema.new(
          :integer,
          one_of: [
            [multiple_of: 3],
            [multiple_of: 5]
          ]
        )

      assert schema == alternative
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 9) == :ok
      assert validate(schema, 10) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 15) == {:error, %{one_of: [], value: 15}}

      assert validate(schema, 4) ==
               {:error,
                %{one_of: [%{multiple_of: 5}, %{multiple_of: 3}], value: 4}}
    end
  end

  describe "keyword one_of (shortcut):" do
    setup do
      %{
        schema:
          Xema.new(:one_of, [
            {:integer, multiple_of: 3},
            {:integer, multiple_of: 5}
          ])
      }
    end

    test "type", %{schema: schema} do
      assert schema ==
               Xema.new(
                 :any,
                 one_of: [
                   {:integer, multiple_of: 3},
                   {:integer, multiple_of: 5}
                 ]
               )
    end
  end
end
