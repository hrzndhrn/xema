defmodule Xema.TupleTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "tuple schema" do
    setup do
      %{schema: Xema.new(:tuple)}
    end

    test "validate/2 with an empty tuple", %{schema: schema} do
      assert validate(schema, {}) == :ok
    end

    test "validate/2 with a tuple of different types", %{schema: schema} do
      assert validate(schema, {1, "bla", 3.4}) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected :tuple, got "not a tuple".|,
                 reason: %{type: :tuple, value: "not a tuple"}
               }
             } = validate(schema, "not a tuple")
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, {42})
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute valid?(schema, 42)
    end
  end

  describe "tuple schema with size" do
    setup do
      %{schema: Xema.new({:tuple, min_items: 2, max_items: 3})}
    end

    test "validate/2 with too short tuple", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected at least 2 items, got {1}.",
                 reason: %{value: {1}, min_items: 2}
               }
             } = validate(schema, {1})
    end

    test "validate/2 with proper tuple", %{schema: schema} do
      assert validate(schema, {1, 2}) == :ok
    end

    test "validate/2 with to long tuple", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected at most 3 items, got {1, 2, 3, 4}.",
                 reason: %{value: {1, 2, 3, 4}, max_items: 3}
               }
             } = validate(schema, {1, 2, 3, 4})
    end
  end

  describe "tuple schema with typed items" do
    setup do
      %{
        integers: Xema.new({:tuple, items: :integer}),
        strings: Xema.new({:tuple, items: :string})
      }
    end

    test "validate/2 integers with empty tuple", %{integers: schema} do
      assert validate(schema, {}) == :ok
    end

    test "validate/2 integers with tuple of integers", %{integers: schema} do
      assert validate(schema, {1, 2}) == :ok
    end

    test "validate/2 integers with invalid tuple", %{integers: schema} do
      assert {:error,
              %ValidationError{
                message: ~s|Expected :integer, got "foo", at [2].|,
                reason: %{
                  items: [
                    {2, %{type: :integer, value: "foo"}}
                  ]
                }
              }} = validate(schema, {1, 2, "foo"})
    end

    test "validate/2 strings with empty tuple", %{strings: schema} do
      assert validate(schema, {}) == :ok
    end

    test "validate/2 strings with tuple of string", %{strings: schema} do
      assert validate(schema, {"foo"}) == :ok
    end

    test "validate/2 strings with invalid tuple", %{strings: schema} do
      msg = """
      Expected :string, got 1, at [0].
      Expected :string, got 2, at [1].\
      """

      assert {:error,
              %ValidationError{
                message: ^msg,
                reason: %{
                  items: [
                    {0, %{type: :string, value: 1}},
                    {1, %{type: :string, value: 2}}
                  ]
                }
              }} = validate(schema, {1, 2, "foo"})
    end
  end

  describe "tuple schema with bool schema for items: " do
    setup do
      %{
        true_schema: Xema.new({:tuple, items: true}),
        false_schema: Xema.new({:tuple, items: false})
      }
    end

    test "validate/2 true schema with empty tuple", %{true_schema: schema} do
      assert validate(schema, {}) == :ok
    end

    test "validate/2 true schema with non empty tuple", %{true_schema: schema} do
      assert validate(schema, {1, "a"}) == :ok
    end

    test "validate/2 false schema with empty tuple", %{false_schema: schema} do
      assert validate(schema, {}) == :ok
    end

    test "validate/2 false schema with non empty tuple", %{false_schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Schema always fails validation.",
                 reason: %{
                   type: false
                 }
               }
             } = validate(schema, {1, "a"})
    end
  end

  describe "tuple schema with unique items" do
    setup do
      %{schema: Xema.new({:tuple, unique_items: true})}
    end

    test "validate/2 with tuple of unique items", %{schema: schema} do
      assert validate(schema, {1, 2, 3}) == :ok
    end

    test "validate/2 with tuple of not unique items", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected unique items, got {1, 2, 3, 3, 4}.",
                 reason: %{value: {1, 2, 3, 3, 4}, unique_items: true}
               }
             } = validate(schema, {1, 2, 3, 3, 4})
    end
  end

  describe "tuple schema with tuple validation" do
    setup do
      %{
        schema:
          Xema.new({
            :tuple,
            items: [
              {:string, min_length: 3},
              {:number, minimum: 10}
            ]
          })
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, {"foo", 42}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected :number, got "bar", at [1].|,
                 reason: %{items: [{1, %{type: :number, value: "bar"}}]}
               }
             } = validate(schema, {"foo", "bar"})

      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected minimum length of 3, got \"x\", at [0].|,
                 reason: %{items: [{0, %{value: "x", min_length: 3}}]}
               }
             } = validate(schema, {"x", 33})
    end

    test "validate/2 with invalid value and additional item", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected minimum length of 3, got \"x\", at [0].|,
                 reason: %{items: [{0, %{value: "x", min_length: 3}}]}
               }
             } = validate(schema, {"x", 33, 7})
    end

    test "validate/2 with additional item", %{schema: schema} do
      assert validate(schema, {"foo", 42, "add"}) == :ok
    end

    test "validate/2 with missing item", %{schema: schema} do
      assert validate(schema, {"foo"}) == :ok
    end
  end

  describe "tuple schema with tuple validation without addtional items" do
    setup do
      %{
        schema:
          Xema.new({
            :tuple,
            additional_items: false,
            items: [
              {:string, min_length: 3},
              {:number, minimum: 10}
            ]
          })
      }
    end

    test "validate/2 with additional item", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Unexpected additional item, at [2].",
                 reason: %{items: [{2, %{additional_items: false}}]}
               }
             } = validate(schema, {"foo", 42, "add"})
    end
  end

  describe "tuple schema with with specific additional items" do
    setup do
      %{
        schema:
          Xema.new({
            :tuple,
            additional_items: :string,
            items: [
              {:number, minimum: 10}
            ]
          })
      }
    end

    test "validate/2 with valid additional item", %{schema: schema} do
      assert validate(schema, {11, "twelve", "thirteen"}) == :ok
    end

    test "validate/2 with invalid additional item", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected :string, got 13, at [2].",
                 reason: %{items: [{2, %{type: :string, value: 13}}]}
               }
             } = validate(schema, {11, "twelve", 13})
    end
  end

  describe "validate/2 tuple contains" do
    setup do
      %{
        schema:
          Xema.new({
            :tuple,
            contains: [minimum: 4]
          })
      }
    end

    test "an element has a value of minium 4", %{schema: schema} do
      assert validate(schema, {2, 3, 4}) == :ok
    end

    test "no element of minimum 4", %{schema: schema} do
      msg = """
      No items match contains.
        Value 1 is less than minimum value of 4, at [0].
        Value 2 is less than minimum value of 4, at [1].
        Value 3 is less than minimum value of 4, at [2].\
      """

      assert {:error,
              %ValidationError{
                message: ^msg,
                reason: %{
                  value: {1, 2, 3},
                  contains: [
                    {0, %{minimum: 4, value: 1}},
                    {1, %{minimum: 4, value: 2}},
                    {2, %{minimum: 4, value: 3}}
                  ]
                }
              }} = validate(schema, {1, 2, 3})
    end
  end

  describe "validate/2 tuple contains (Xema)" do
    setup do
      minimum = Xema.new(minimum: 4)

      %{
        schema:
          Xema.new({
            :tuple,
            contains: minimum
          })
      }
    end

    test "an element has a value of minium 4", %{schema: schema} do
      assert validate(schema, {2, 3, 4}) == :ok
    end

    test "no element of minimum 4", %{schema: schema} do
      msg = """
      No items match contains.
        Value 1 is less than minimum value of 4, at [0].
        Value 2 is less than minimum value of 4, at [1].
        Value 3 is less than minimum value of 4, at [2].\
      """

      assert {
               :error,
               %ValidationError{
                 message: ^msg,
                 reason: %{
                   value: {1, 2, 3},
                   contains: [
                     {0, %{minimum: 4, value: 1}},
                     {1, %{minimum: 4, value: 2}},
                     {2, %{minimum: 4, value: 3}}
                   ]
                 }
               }
             } = validate(schema, {1, 2, 3})
    end
  end
end
