defmodule Xema.OneOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "keyword one_of (multiple_of):" do
    setup do
      %{
        schema:
          Xema.new({
            :any,
            one_of: [
              {:integer, multiple_of: 3},
              {:integer, multiple_of: 5},
              {:integer, multiple_of: 30}
            ]
          })
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 9) == :ok
      assert validate(schema, 10) == :ok
    end

    test "validate/2 with an invalid value that matched more than one schema", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{one_of: {:ok, [0, 1]}, value: 15}
               } = error
             } = validate(schema, 15)

      assert Exception.message(error) == "More as one schema matches (indexes: [0, 1])."
    end

    test "validate/2 with an invalid value that matched all schemas", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{one_of: {:ok, [0, 1, 2]}, value: 30}
               } = error
             } = validate(schema, 30)

      assert Exception.message(error) == "More as one schema matches (indexes: [0, 1, 2])."
    end

    test "validate/2 with an invalid value that matched no schema", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   one_of:
                     {:error,
                      [
                        %{multiple_of: 3, value: 4},
                        %{multiple_of: 5, value: 4},
                        %{multiple_of: 30, value: 4}
                      ]},
                   value: 4
                 }
               } = error
             } = validate(schema, 4)

      message = """
      No match of any schema.
        Value 4 is not a multiple of 3.
        Value 4 is not a multiple of 5.
        Value 4 is not a multiple of 30.\
      """

      assert Exception.message(error) == message
    end
  end

  describe "keyword one_of (multiple_of integer):" do
    setup do
      %{
        schema:
          Xema.new({
            :integer,
            one_of: [
              [multiple_of: 3],
              [multiple_of: 5]
            ]
          })
      }
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 9) == :ok
      assert validate(schema, 10) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{one_of: {:ok, [0, 1]}, value: 15}
               } = error
             } = validate(schema, 15)

      assert Exception.message(error) == "More as one schema matches (indexes: [0, 1])."

      assert {
               :error,
               %ValidationError{
                 reason: %{
                   one_of: {:error, [%{multiple_of: 3, value: 4}, %{multiple_of: 5, value: 4}]},
                   value: 4
                 }
               } = error
             } = validate(schema, 4)

      message = """
      No match of any schema.
        Value 4 is not a multiple of 3.
        Value 4 is not a multiple of 5.\
      """

      assert Exception.message(error) == message
    end
  end

  describe "keyword one_of (shortcut):" do
    setup do
      %{
        schema:
          Xema.new(
            one_of: [
              {:integer, multiple_of: 3},
              {:integer, multiple_of: 5}
            ]
          )
      }
    end

    test "type", %{schema: schema} do
      assert schema ==
               Xema.new({
                 :any,
                 one_of: [
                   {:integer, multiple_of: 3},
                   {:integer, multiple_of: 5}
                 ]
               })
    end
  end

  describe "one_of required" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             properties: %{
               a: :integer,
               b: :integer
             },
             additional_properties: false,
             one_of: [
               [required: [:a]],
               [required: [:b]]
             ]}
          )
      }
    end

    test "validate/2 with an invalid map", %{schema: schema} do
      assert validate(schema, %{a: 5, b: 6}) ==
               {:error,
                %ValidationError{
                  message: nil,
                  reason: %{one_of: {:ok, [0, 1]}, value: %{a: 5, b: 6}}
                }}
    end
  end

  describe "one_of type or minimum" do
    setup do
      %{schema: Xema.new(one_of: [:integer, [minimum: 2]])}
    end

    test "with an invalid value", %{schema: schema} do
      assert validate(schema, 3) ==
               {:error,
                %Xema.ValidationError{
                  reason: %{one_of: {:ok, [0, 1]}, value: 3}
                }}
    end
  end
end
