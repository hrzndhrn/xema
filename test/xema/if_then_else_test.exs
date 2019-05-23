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
      assert {:error,
              %ValidationError{
                reason: %{then: %{min_length: 1, value: ""}}
              } = error} = validate(schema, "")

      message = """
      Schema for then does not match.
        Expected minimum length of 1, got "".\
      """

      assert Exception.message(error) == message
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
                 reason: %{else: %{min_length: 1, value: ""}}
               } = error
             } = validate(schema, "")

      message = """
      Schema for else does not match.
        Expected minimum length of 1, got "".\
      """

      assert Exception.message(error) == message
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
      assert {:error,
              %ValidationError{
                reason: %{else: %{type: :integer, value: 1.1}}
              } = error} = validate(schema, 1.1)

      message = """
      Schema for else does not match.
        Expected :integer, got 1.1.\
      """

      assert Exception.message(error) == message

      assert {:error,
              %ValidationError{
                reason: %{then: %{min_items: 2, value: []}}
              } = error} = validate(schema, [])

      message = """
      Schema for then does not match.
        Expected at least 2 items, got [].\
      """

      assert Exception.message(error) == message

      assert {:error,
              %ValidationError{
                reason: %{
                  then: %{
                    items: [
                      {2, %{type: :integer, value: "foo"}},
                      {3, %{type: :integer, value: "bar"}}
                    ]
                  }
                }
              } = error} = validate(schema, [1, 2, "foo", "bar"])

      message = """
      Schema for then does not match.
        Expected :integer, got "foo", at [2].
        Expected :integer, got "bar", at [3].\
      """

      assert Exception.message(error) == message
    end
  end
end
