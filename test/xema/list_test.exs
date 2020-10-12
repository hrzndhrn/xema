defmodule Xema.ListTest do
  use ExUnit.Case, async: true

  import AssertBlame
  import Xema, only: [valid?: 2, validate: 2, validate!: 2]

  alias Xema.{Schema, ValidationError}

  describe "'list' schema" do
    setup do
      %{schema: Xema.new(:list)}
    end

    test "validate/2 with an empty list", %{schema: schema} do
      assert validate(schema, []) == :ok
    end

    test "validate/2 with an list of different types", %{schema: schema} do
      assert validate(schema, [1, "bla", 3.4]) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  type: :list,
                  value: "not an array"
                }
              } = error} = validate(schema, "not an array")

      assert Exception.message(error) == ~s|Expected :list, got "not an array".|
    end

    test "validate!/2 with an invalid value", %{schema: schema} do
      msg = ~s|Expected :list, got "not an array".|

      assert_blame ValidationError, msg, fn ->
        validate!(schema, "not an array")
      end
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, [1])
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute valid?(schema, 42)
    end
  end

  describe "'list' schema with size" do
    setup do
      %{schema: Xema.new({:list, min_items: 2, max_items: 3})}
    end

    test "validate/2 with too short list", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  value: [1],
                  min_items: 2
                }
              } = error} = validate(schema, [1])

      assert Exception.message(error) == "Expected at least 2 items, got [1]."
    end

    test "validate/2 with proper list", %{schema: schema} do
      assert validate(schema, [1, 2]) == :ok
    end

    test "validate/2 with to long list", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  value: [1, 2, 3, 4],
                  max_items: 3
                }
              } = error} = validate(schema, [1, 2, 3, 4])

      assert Exception.message(error) == "Expected at most 3 items, got [1, 2, 3, 4]."
    end
  end

  describe "'list' schema with typed items" do
    setup do
      %{
        integers: Xema.new({:list, items: :integer}),
        strings: Xema.new({:list, items: :string})
      }
    end

    test "validate/2 integers with empty list", %{integers: schema} do
      assert validate(schema, []) == :ok
    end

    test "validate/2 integers with list of integers", %{integers: schema} do
      assert validate(schema, [1, 2]) == :ok
    end

    test "validate/2 integers with invalid list", %{integers: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  items: %{2 => %{type: :integer, value: "foo"}}
                }
              } = error} = validate(schema, [1, 2, "foo"])

      assert Exception.message(error) == ~s|Expected :integer, got "foo", at [2].|
    end

    test "validate/2 strings with empty list", %{strings: schema} do
      assert validate(schema, []) == :ok
    end

    test "validate/2 strings with list of string", %{strings: schema} do
      assert validate(schema, ["foo"]) == :ok
    end

    test "validate/2 strings with invalid list", %{strings: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   items: %{
                     0 => %{type: :string, value: 1},
                     1 => %{type: :string, value: 2}
                   }
                 }
               } = error
             } = validate(schema, [1, 2, "foo"])

      message = """
      Expected :string, got 1, at [0].
      Expected :string, got 2, at [1].\
      """

      assert Exception.message(error) == message
    end
  end

  describe "list schema with bool schema for items: " do
    setup do
      %{
        true_schema: Xema.new({:list, items: true}),
        false_schema: Xema.new({:list, items: false})
      }
    end

    test "validate/2 true schema with empty list", %{true_schema: schema} do
      assert validate(schema, []) == :ok
    end

    test "validate/2 true schema with non empty list", %{true_schema: schema} do
      assert validate(schema, [1, "a"]) == :ok
    end

    test "validate/2 false schema with empty list", %{false_schema: schema} do
      assert validate(schema, []) == :ok
    end

    test "validate/2 false schema with non empty list", %{false_schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  type: false
                }
              } = error} = validate(schema, [1, "a"])

      assert Exception.message(error) == "Schema always fails validation."
    end
  end

  describe "'list' schema with unique items" do
    setup do
      %{schema: Xema.new({:list, unique_items: true})}
    end

    test "validate/2 with list of unique items", %{schema: schema} do
      assert validate(schema, [1, 2, 3]) == :ok
    end

    test "validate/2 with list of not unique items", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{value: [1, 2, 3, 3, 4], unique_items: true}
               } = error
             } = validate(schema, [1, 2, 3, 3, 4])

      assert Exception.message(error) == "Expected unique items, got [1, 2, 3, 3, 4]."
    end
  end

  describe "'list' schema with unique items set to false" do
    setup do
      %{schema: Xema.new({:list, unique_items: false})}
    end

    test "validate/2 with list of unique items", %{schema: schema} do
      assert validate(schema, [1, 2, 3]) == :ok
    end

    test "validate/2 with list of not unique items", %{schema: schema} do
      assert validate(schema, [1, 2, 3, 3, 4]) == :ok
    end
  end

  describe "'list' schema with tuple validation" do
    setup do
      %{
        schema:
          Xema.new({
            :list,
            items: [
              {:string, min_length: 3},
              {:number, minimum: 10}
            ]
          })
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, ["foo", 42]) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   items: %{1 => %{type: :number, value: "bar"}}
                 }
               } = error
             } = validate(schema, ["foo", "bar"])

      assert Exception.message(error) == ~s|Expected :number, got "bar", at [1].|

      assert {
               :error,
               %ValidationError{
                 reason: %{
                   items: %{0 => %{value: "x", min_length: 3}}
                 }
               } = error
             } = validate(schema, ["x", 33])

      assert Exception.message(error) == ~s|Expected minimum length of 3, got "x", at [0].|
    end

    test "validate/2 with invalid value and additional item", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{items: %{0 => %{value: "x", min_length: 3}}}
               } = error
             } = validate(schema, ["x", 33, 7])

      assert Exception.message(error) == ~s|Expected minimum length of 3, got \"x\", at [0].|
    end

    test "validate/2 with additional item", %{schema: schema} do
      assert validate(schema, ["foo", 42, "add"]) == :ok
    end

    test "validate/2 with missing item", %{schema: schema} do
      assert validate(schema, ["foo"]) == :ok
    end
  end

  describe "'list' schema with tuple validation without addtional items" do
    setup do
      %{
        schema:
          Xema.new({
            :list,
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
                 reason: %{items: %{2 => %{additional_items: false}}}
               } = error
             } = validate(schema, ["foo", 42, "add"])

      assert Exception.message(error) == "Unexpected additional item, at [2]."
    end
  end

  describe "list schema with with specific additional items" do
    setup do
      %{
        schema:
          Xema.new({
            :list,
            additional_items: :string,
            items: [
              {:number, minimum: 10}
            ]
          })
      }
    end

    test "validate/2 with valid additional item", %{schema: schema} do
      assert validate(schema, [11, "twelve", "thirteen"]) == :ok
    end

    test "validate/2 with invalid additional item", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   items: %{2 => %{type: :string, value: 13}}
                 }
               } = error
             } = validate(schema, [11, "twelve", 13])

      assert Exception.message(error) == "Expected :string, got 13, at [2]."
    end
  end

  describe "validate/2 list contains" do
    setup do
      %{
        schema:
          Xema.new({
            :list,
            contains: [minimum: 4]
          })
      }
    end

    test "an element has a value of minium 4", %{schema: schema} do
      assert validate(schema, [2, 3, 4]) == :ok
    end

    test "no element of minimum 4", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   value: [2, 3],
                   contains: [
                     {0, %{minimum: 4, value: 2}},
                     {1, %{minimum: 4, value: 3}}
                   ]
                 }
               } = error
             } = validate(schema, [2, 3])

      message = """
      No items match contains.
        Value 2 is less than minimum value of 4, at [0].
        Value 3 is less than minimum value of 4, at [1].\
      """

      assert Exception.message(error) == message
    end
  end

  describe "validate/2 list contains (Xema)" do
    setup do
      minimum = Xema.new(minimum: 4)

      %{
        schema:
          Xema.new({
            :list,
            contains: minimum
          })
      }
    end

    test "check xema", %{schema: schema} do
      assert schema == %Xema{
               refs: %{},
               schema: %Schema{
                 contains: %Schema{minimum: 4},
                 type: :list
               }
             }
    end

    test "an element has a value of minium 4", %{schema: schema} do
      assert validate(schema, [2, 3, 4]) == :ok
    end

    test "no element of minimum 4", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   value: [1, 2, 3],
                   contains: [
                     {0, %{minimum: 4, value: 1}},
                     {1, %{minimum: 4, value: 2}},
                     {2, %{minimum: 4, value: 3}}
                   ]
                 }
               } = error
             } = validate(schema, [1, 2, 3])

      message = """
      No items match contains.
        Value 1 is less than minimum value of 4, at [0].
        Value 2 is less than minimum value of 4, at [1].
        Value 3 is less than minimum value of 4, at [2].\
      """

      assert Exception.message(error) == message
    end
  end

  describe "validate/2 with list items (Xema)" do
    setup do
      string = Xema.new(:string)

      %{
        schema: Xema.new({:list, items: string})
      }
    end

    test "check xema", %{schema: schema} do
      assert schema == %Xema{
               refs: %{},
               schema: %Schema{
                 items: %Schema{type: :string},
                 type: :list
               }
             }
    end

    test "return ok for valid data", %{schema: schema} do
      assert Xema.validate(schema, ["a", "b"]) == :ok
    end

    test "return error tuple for invalid data", %{schema: schema} do
      assert Xema.validate(schema, ["a", 1]) ==
               {:error,
                %Xema.ValidationError{
                  message: nil,
                  reason: %{items: %{1 => %{type: :string, value: 1}}}
                }}
    end
  end
end
