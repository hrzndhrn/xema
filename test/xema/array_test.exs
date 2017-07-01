defmodule Xema.ArrayTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  alias Xema.Array

  setup do
    %{
      array: Xema.create(:array),
      length: Xema.create(:array, min_items: 2, max_items: 3),
      integers: Xema.create(:array, items: Xema.create(:integer)),
      tuple: Xema.create(:array, items: [Xema.create(:string),
                                         Xema.create(:integer)]),
      tuple_add: Xema.create(:array,
                             additional_items: true,
                             items: [Xema.create(:string),
                                     Xema.create(:integer)])
    }
  end

  test "type and properties", schemas do
    assert schemas.array.type == :array
    assert schemas.array.properties == %Array{items: nil}

    assert schemas.length.type == :array
  end

  describe "validate/2" do
    test "with an empty list", %{array: schema},
      do: assert validate(schema, []) == :ok

    test "with an list of different types", %{array: schema},
      do: assert validate(schema, [1, "bla", 3.4]) == :ok

    test "with different type", %{array: schema},
      do: assert validate(schema, "not an array") == {:error, %{type: :array}}

    test "to short list", %{length: schema},
      do: assert validate(schema, [1]) == {:error, %{min_items: 2}}

    test "proper list", %{length: schema},
      do: assert validate(schema, [1, 2]) == :ok

    test "to long list", %{length: schema},
      do: assert validate(schema, [1, 2, 3, 4]) == {:error, %{max_items: 3}}

    test "integer items with list of integers", %{integers: schema},
      do: assert validate(schema, [1, 2]) == :ok

    test "integer items with invalid list", %{integers: schema} do
      expected = {
        :error,
        :nested,
        %{
          at: 2,
          error: {:error, :wrong_type, %{type: :integer}}
        }
      }
      assert validate(schema, [1, 2, "a", 3]) == expected
    end

    test "tuple with valid values", %{tuple: schema},
      do: assert validate(schema, ["a", 2]) == :ok

    test "tuple with invalid values", %{tuple: schema} do
      expected = {
        :error,
        :nested,
        %{
          at: 0,
          error: {:error, :wrong_type, %{type: :string}}
        }
      }
      assert validate(schema, [2, "a"]) == expected
    end

    test "tuple with too less values", %{tuple: schema} do
      expected = {:error, :missing_value, %{at: 1}}
      assert validate(schema, ["a"]) == expected
    end

    test "tuple with more values", %{tuple: schema},
      do: assert validate(schema, ["a", 2, "too many"]) == :ok

    test "tuple with too many values", %{tuple_add: schema} do
      expected = {:error, :extra_value, %{at: 2}}
      assert validate(schema, ["a", 2, "too many"]) == expected
    end
  end
end
