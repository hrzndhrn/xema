defmodule Xema.TupleTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

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
      expected = {:error, %{type: :tuple, value: "not a tuple"}}

      assert validate(schema, "not a tuple") == expected
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
      %{schema: Xema.new(:tuple, min_items: 2, max_items: 3)}
    end

    test "validate/2 with too short tuple", %{schema: schema} do
      assert validate(schema, {1}) == {:error, %{value: {1}, min_items: 2}}
    end

    test "validate/2 with proper tuple", %{schema: schema} do
      assert validate(schema, {1, 2}) == :ok
    end

    test "validate/2 with to long tuple", %{schema: schema} do
      assert validate(schema, {1, 2, 3, 4}) ==
               {:error, %{value: {1, 2, 3, 4}, max_items: 3}}
    end
  end

  describe "tuple schema with typed items" do
    setup do
      %{
        integers: Xema.new(:tuple, items: :integer),
        strings: Xema.new(:tuple, items: :string)
      }
    end

    test "validate/2 integers with empty tuple", %{integers: schema} do
      assert validate(schema, {}) == :ok
    end

    test "validate/2 integers with tuple of integers", %{integers: schema} do
      assert validate(schema, {1, 2}) == :ok
    end

    test "validate/2 integers with invalid tuple", %{integers: schema} do
      expected =
        {:error,
         %{
           items: [
             {2, %{type: :integer, value: "foo"}}
           ]
         }}

      assert validate(schema, {1, 2, "foo"}) == expected
    end

    test "validate/2 strings with empty tuple", %{strings: schema} do
      assert validate(schema, {}) == :ok
    end

    test "validate/2 strings with tuple of string", %{strings: schema} do
      assert validate(schema, {"foo"}) == :ok
    end

    test "validate/2 strings with invalid tuple", %{strings: schema} do
      expected = {
        :error,
        %{
          items: [
            {0, %{type: :string, value: 1}},
            {1, %{type: :string, value: 2}}
          ]
        }
      }

      assert validate(schema, {1, 2, "foo"}) == expected
    end
  end

  describe "tuple schema with bool schema for items: " do
    setup do
      %{
        true_schema: Xema.new(:tuple, items: true),
        false_schema: Xema.new(:tuple, items: false)
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
      assert validate(schema, {1, "a"}) == {:error, %{type: false}}
    end
  end

  describe "tuple schema with unique items" do
    setup do
      %{schema: Xema.new(:tuple, unique_items: true)}
    end

    test "validate/2 with tuple of unique items", %{schema: schema} do
      assert validate(schema, {1, 2, 3}) == :ok
    end

    test "validate/2 with tuple of not unique items", %{schema: schema} do
      assert validate(schema, {1, 2, 3, 3, 4}) ==
               {:error, %{value: {1, 2, 3, 3, 4}, unique_items: true}}
    end
  end

  describe "tuple schema with tuple validation" do
    setup do
      %{
        schema:
          Xema.new(
            :tuple,
            items: [
              {:string, min_length: 3},
              {:number, minimum: 10}
            ]
          )
      }
    end

    test "validate/2 with valid values", %{schema: schema} do
      assert validate(schema, {"foo", 42}) == :ok
    end

    test "validate/2 with invalid values", %{schema: schema} do
      assert validate(schema, {"foo", "bar"}) ==
               {:error, %{items: [{1, %{type: :number, value: "bar"}}]}}

      assert validate(schema, {"x", 33}) ==
               {:error, %{items: [{0, %{value: "x", min_length: 3}}]}}
    end

    test "validate/2 with invalid value and additional item", %{schema: schema} do
      assert validate(schema, {"x", 33, 7}) ==
               {:error, %{items: [{0, %{value: "x", min_length: 3}}]}}
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
          Xema.new(
            :tuple,
            additional_items: false,
            items: [
              {:string, min_length: 3},
              {:number, minimum: 10}
            ]
          )
      }
    end

    test "validate/2 with additional item", %{schema: schema} do
      assert validate(schema, {"foo", 42, "add"}) ==
               {:error, %{items: [{2, %{additional_items: false}}]}}
    end
  end

  describe "tuple schema with with specific additional items" do
    setup do
      %{
        schema:
          Xema.new(
            :tuple,
            additional_items: :string,
            items: [
              {:number, minimum: 10}
            ]
          )
      }
    end

    test "validate/2 with valid additional item", %{schema: schema} do
      assert validate(schema, {11, "twelve", "thirteen"}) == :ok
    end

    test "validate/2 with invalid additional item", %{schema: schema} do
      assert validate(schema, {11, "twelve", 13}) ==
               {:error, %{items: [{2, %{type: :string, value: 13}}]}}
    end
  end

  describe "validate/2 tuple contains" do
    setup do
      %{
        schema:
          Xema.new(
            :tuple,
            contains: [minimum: 4]
          )
      }
    end

    test "an element has a value of minium 4", %{schema: schema} do
      assert validate(schema, {2, 3, 4}) == :ok
    end

    test "no element of minimum 4", %{schema: schema} do
      assert validate(schema, {1, 2, 3}) ==
               {:error,
                %{value: {1, 2, 3}, contains: Xema.new(minimum: 4).content}}
    end
  end

  describe "validate/2 tuple contains (Xema)" do
    setup do
      minimum = Xema.new(minimum: 4)

      %{
        schema:
          Xema.new(
            :tuple,
            contains: minimum
          )
      }
    end

    test "an element has a value of minium 4", %{schema: schema} do
      assert validate(schema, {2, 3, 4}) == :ok
    end

    test "no element of minimum 4", %{schema: schema} do
      assert validate(schema, {1, 2, 3}) ==
               {:error,
                %{value: {1, 2, 3}, contains: Xema.new(minimum: 4).content}}
    end
  end
end
