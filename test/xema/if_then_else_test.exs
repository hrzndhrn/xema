defmodule Xema.IfThenElseTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

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
      assert validate(schema, "") == {
               :error,
               %ValidationError{
                 message: """
                 Schema for then does not match.
                   Expected minimum length of 1, got "".\
                 """,
                 reason: %{then: %{min_length: 1, value: ""}}
               }
             }
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
      assert {
               :error,
               %ValidationError{
                 message: """
                 Schema for else does not match.
                   Expected minimum length of 1, got "".\
                 """,
                 reason: %{else: %{min_length: 1, value: ""}}
               }
             } = validate(schema, "")
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
      assert validate(schema, 1.1) == {
               :error,
               %ValidationError{
                 message: """
                 Schema for else does not match.
                   Expected :integer, got 1.1.\
                 """,
                 reason: %{else: %{type: :integer, value: 1.1}}
               }
             }

      assert validate(schema, []) == {
               :error,
               %ValidationError{
                 message: """
                 Schema for then does not match.
                   Expected at least 2 items, got [].\
                 """,
                 reason: %{then: %{min_items: 2, value: []}}
               }
             }

      assert validate(schema, [1, 2, "foo", "bar"]) == {
               :error,
               %ValidationError{
                 message: """
                 Schema for then does not match.
                   Expected :integer, got "foo", at [2].
                   Expected :integer, got "bar", at [3].\
                 """,
                 reason: %{
                   then: %{
                     items: [
                       {2, %{type: :integer, value: "foo"}},
                       {3, %{type: :integer, value: "bar"}}
                     ]
                   }
                 }
               }
             }
    end
  end
end
