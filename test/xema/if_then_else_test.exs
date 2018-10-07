defmodule Xema.IfThenElseTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  describe "if then" do
    setup do
      %{
        schema:
          Xema.new(
            if: :string,
            then: [min_length: 1]
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, "bla") == :ok
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "") ==
               {:error, %{then: %{min_length: 1, value: ""}}}
    end
  end

  describe "if else" do
    setup do
      %{
        schema:
          Xema.new(
            if: :list,
            else: [min_length: 1]
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, []) == :ok
      assert validate(schema, "foo") == :ok
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, "") ==
               {:error, %{else: %{min_length: 1, value: ""}}}
    end
  end

  describe "if then else" do
    setup do
      %{
        schema:
          Xema.new(
            if: :list,
            then: [items: :integer, min_items: 2],
            else: :integer
          )
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, [1, 2]) == :ok
      assert validate(schema, 1) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 1.1) ==
               {:error, %{else: %{type: :integer, value: 1.1}}}

      assert validate(schema, []) ==
               {:error, %{then: %{min_items: 2, value: []}}}

      assert validate(schema, [1, 2, "foo", "bar"]) ==
               {:error,
                %{
                  then: %{
                    items: [
                      {2, %{type: :integer, value: "foo"}},
                      {3, %{type: :integer, value: "bar"}}
                    ]
                  }
                }}
    end
  end
end
