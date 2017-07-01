defmodule Xema.ListTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  alias Xema.List

  setup do
    %{
      array: Xema.create(:list),
      unique: Xema.create(:list, unique_items: true),
      length: Xema.create(:list, min_items: 2, max_items: 3),
      integers: Xema.create(:list, items: Xema.create(:integer)),
      tuple: Xema.create(:list, items: [Xema.create(:string),
                                        Xema.create(:integer)]),
      tuple_add: Xema.create(:list,
                             additional_items: true,
                             items: [Xema.create(:string),
                                     Xema.create(:integer)])
    }
  end

  test "type and keywords", schemas do
    assert schemas.array.type == :list
    assert schemas.array.keywords == %List{items: nil}

    assert schemas.length.type == :list
  end

  describe "validate/2" do
    test "with an empty list", %{array: schema},
      do: assert validate(schema, []) == :ok

    test "with an list of different types", %{array: schema},
      do: assert validate(schema, [1, "bla", 3.4]) == :ok

    test "with different type", %{array: schema} do
      expected = {:error, :wrong_type, %{type: :list}}
      assert validate(schema, "not an array") == expected
    end

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

    test "list with unique items", %{unique: schema},
      do: assert validate(schema, [1, 2, 3]) == :ok

    test "list with none unique items", %{unique: schema} do
      expected = {:error, :not_unique, %{}}
      assert validate(schema, [1, 2, 2]) == expected
    end
  end
end
