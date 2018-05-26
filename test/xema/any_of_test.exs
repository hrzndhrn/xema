defmodule Xema.AnyOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

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
      assert schema.content.type == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
      assert validate(schema, nil) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      expected =
        {:error,
         %{
           any_of: [
             %{type: nil},
             %{type: :integer}
           ],
           value: "foo"
         }}

      assert validate(schema, "foo") == expected
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
end
