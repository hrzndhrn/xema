defmodule Xema.AllOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  describe "keyword all_of:" do
    setup do
      %{
        schema:
          Xema.new({
            :any,
            all_of: [:integer, {:integer, minimum: 0}]
          })
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an imvalid value", %{schema: schema} do
      assert validate(schema, -1) ==
               {:error, %{all_of: [%{minimum: 0, value: -1}], value: -1}}
    end
  end

  describe "keyword all_of (shortcut):" do
    setup do
      %{
        schema: Xema.new(all_of: [:integer, {:integer, minimum: 0}])
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema ==
               Xema.new({
                 :any,
                 all_of: [:integer, {:integer, minimum: 0}]
               })
    end
  end
end
