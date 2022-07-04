defmodule Xema.Cast.ListTest do
  use ExUnit.Case, async: true

  import AssertBlame
  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  alias Xema.{CastError, ValidationError}

  @set [:atom, "str", 1.1, 1]

  #
  # Xema.cast/2
  #

  describe "cast/2 with a minimal list schema" do
    setup do
      %{
        schema: Xema.new(:list)
      }
    end

    test "from an empty list", %{schema: schema} do
      data = []
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a list", %{schema: schema} do
      data = [:foo, 42, "bar", 1.1, [1, 2], {:a, "a"}]
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a tuple", %{schema: schema} do
      data = {:foo, 42, "bar", 1.1, [1, 2], {:a, "a"}}
      expected = [:foo, 42, "bar", 1.1, [1, 2], {:a, "a"}]

      assert {:error,
              %ValidationError{
                reason: %{
                  type: :list,
                  value: ^data
                }
              }} = validate(schema, data)

      assert cast(schema, data) == {:ok, expected}
    end

    test "form a keyword list", %{schema: schema} do
      data = [foo: 1]
      expected = [{:foo, 1}]
      assert cast(schema, data) == {:ok, expected}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: :list, value: data)}

        assert cast(schema, data) == expected
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise Protocol.UndefinedError, fn -> cast(schema, ~r/.*/) end
    end
  end

  describe "cast/2 with list schema" do
    setup do
      %{
        schema: Xema.new({:list, items: :integer})
      }
    end

    test "from a list of integers", %{schema: schema} do
      data = [1, 2, 3]
      assert cast(schema, data) == {:ok, data}
    end

    test "from a list of integer strings", %{schema: schema} do
      assert cast(schema, ["1", "2", "3"]) == {:ok, [1, 2, 3]}
    end

    test "from a tuple with integer strings", %{schema: schema} do
      assert cast(schema, {"1", "2", "3"}) == {:ok, [1, 2, 3]}
    end

    test "from a list with invalid value", %{schema: schema} do
      data = ["1", "2", "foo"]
      expected = {:error, CastError.exception(path: [2], to: :integer, value: "foo")}

      assert cast(schema, data) == expected
    end
  end

  describe "cast/2 with tuple schema and additional items schema" do
    setup do
      %{
        schema: Xema.new({:list, items: [:string], additional_items: :integer})
      }
    end

    test "from a list with a valid addition item", %{schema: schema} do
      assert cast(schema, [5, "6"]) == {:ok, ["5", 6]}
    end

    test "from a list with an invalid addition item", %{schema: schema} do
      assert cast(schema, [5, "six"]) ==
               {:error, %CastError{key: nil, message: nil, path: [1], to: :integer, value: "six"}}
    end
  end

  describe "cast/2 with tuple schema" do
    setup do
      %{
        schema: Xema.new({:list, items: [:integer, :string]})
      }
    end

    test "from a list with casted values", %{schema: schema} do
      data = [1, "two"]
      assert cast(schema, data) == {:ok, data}
    end

    test "from a list castable values", %{schema: schema} do
      assert cast(schema, ["1", 2]) == {:ok, [1, "2"]}
    end

    test "from a list with additional items", %{schema: schema} do
      assert cast(schema, ["1", 2, :add, {:tuple}]) == {:ok, [1, "2", :add, {:tuple}]}
    end

    test "from a list with invalid value", %{schema: schema} do
      data = ["foo", 2]
      expected = {:error, CastError.exception(path: [0], to: :integer, value: "foo")}

      assert cast(schema, data) == expected
    end

    test "from a tuple with casted values", %{schema: schema} do
      assert cast(schema, {1, "two"}) == {:ok, [1, "two"]}
    end

    test "from a tuple with castable values", %{schema: schema} do
      assert cast(schema, {"1", 2}) == {:ok, [1, "2"]}
    end

    test "from a tuple with additional items", %{schema: schema} do
      assert cast(schema, {"1", 2, :add, {:tuple}}) == {:ok, [1, "2", :add, {:tuple}]}
    end

    test "from a tuple with invalid value", %{schema: schema} do
      assert cast(schema, {"foo", 2}) ==
               {:error, CastError.exception(path: [0], to: :integer, value: "foo")}
    end

    test "from a map with integer keys", %{schema: schema} do
      assert cast(schema, %{0 => "1", 1 => 2, 4 => :add}) == {:ok, [1, "2", :add]}
    end

    test "from a map with string keys", %{schema: schema} do
      assert cast(schema, %{"0" => "1", "1" => 2, "4" => :add}) == {:ok, [1, "2", :add]}
    end

    test "from a map with non-continuous keys", %{schema: schema} do
      assert cast(schema, %{"10" => "1", "1" => 2, "4" => :add}) == {:ok, [2, "add", "1"]}
    end

    test "from an invalid value", %{schema: schema} do
      assert cast(schema, :foo) ==
               {:error, CastError.exception(to: :list, path: [], value: :foo)}
    end
  end

  describe "cast/2 with properties" do
    setup do
      %{schema: Xema.new({:list, properties: %{foo: :integer}})}
    end

    test "ignores properties for list", %{schema: schema} do
      assert cast(schema, {"a"}) == {:ok, ["a"]}
    end
  end

  describe "cast/2 with nested schema" do
    setup do
      %{
        schema: Xema.new({:list, items: {:list, items: {:list, items: [:integer, :string]}}})
      }
    end

    test "from valid data", %{schema: schema} do
      assert cast(schema, [[[1, "1"], ["2", 2]], [{"3", 3}]]) ==
               {:ok, [[[1, "1"], [2, "2"]], [[3, "3"]]]}
    end

    test "from invalid data", %{schema: schema} do
      data = [[[1, "1"], ["foo", 2]], [{"3", 3}]]
      expected = {:error, CastError.exception(path: [0, 1, 0], to: :integer, value: "foo")}

      assert cast(schema, data) == expected
    end
  end

  #
  # Xema.cast!/2
  #

  describe "cast!/2 with a minimal list schema" do
    setup do
      %{
        schema: Xema.new(:list)
      }
    end

    test "from an empty list", %{schema: schema} do
      data = []
      assert validate(schema, data) == :ok
      assert cast!(schema, data) == data
    end

    test "from a list", %{schema: schema} do
      data = [:foo, 42, "bar", 1.1, [1, 2], {:a, "a"}]
      assert validate(schema, data) == :ok
      assert cast!(schema, data) == data
    end

    test "from a tuple", %{schema: schema} do
      data = {:foo, 42, "bar", 1.1, [1, 2], {:a, "a"}}
      expected = [:foo, 42, "bar", 1.1, [1, 2], {:a, "a"}]

      assert {
               :error,
               %ValidationError{
                 reason: %{type: :list, value: ^data}
               }
             } = validate(schema, data)

      assert cast!(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :list"

        assert_blame CastError, msg, fn -> cast!(schema, data) end
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise Protocol.UndefinedError, fn -> cast!(schema, ~r/.*/) end
    end
  end

  describe "cast!/2 with list schema" do
    setup do
      %{
        schema: Xema.new({:list, items: :integer})
      }
    end

    test "from a list of integers", %{schema: schema} do
      data = [1, 2, 3]
      assert cast!(schema, data) == data
    end

    test "from a list of integer strings", %{schema: schema} do
      assert cast!(schema, ["1", "2", "3"]) == [1, 2, 3]
    end

    test "from a tuple with integer strings", %{schema: schema} do
      assert cast!(schema, {"1", "2", "3"}) == [1, 2, 3]
    end

    test "from a list with invalid value", %{schema: schema} do
      msg = ~s|cannot cast "foo" to :integer at [2]|
      assert_blame CastError, msg, fn -> cast!(schema, ["1", "2", "foo"]) end
    end
  end

  describe "cast!/2 with tuple schema" do
    setup do
      %{
        schema: Xema.new({:list, items: [:integer, :string]})
      }
    end

    test "from a list with casted values", %{schema: schema} do
      data = [1, "two"]
      assert cast!(schema, data) == data
    end

    test "from a list castable values", %{schema: schema} do
      assert cast!(schema, ["1", 2]) == [1, "2"]
    end

    test "from a list with additional items", %{schema: schema} do
      assert cast!(schema, ["1", 2, :add, {:tuple}]) == [1, "2", :add, {:tuple}]
    end

    test "from a list with invalid value", %{schema: schema} do
      msg = ~s|cannot cast "foo" to :integer at [0]|
      assert_blame CastError, msg, fn -> cast!(schema, ["foo", 2]) end
    end

    test "from a tuple with casted values", %{schema: schema} do
      assert cast!(schema, {1, "two"}) == [1, "two"]
    end

    test "from a tuple with castable values", %{schema: schema} do
      assert cast!(schema, {"1", 2}) == [1, "2"]
    end

    test "from a tuple with additional items", %{schema: schema} do
      assert cast!(schema, {"1", 2, :add, {:tuple}}) == [1, "2", :add, {:tuple}]
    end

    test "from a tuple with invalid value", %{schema: schema} do
      msg = ~s|cannot cast "foo" to :integer at [0]|
      assert_blame CastError, msg, fn -> cast!(schema, {"foo", 2}) end
    end

    test "from an invalid value", %{schema: schema} do
      msg = ~s|cannot cast "foo" to :list|
      assert_blame CastError, msg, fn -> cast!(schema, "foo") end
    end

    test "from an invalid map", %{schema: schema} do
      msg = ~s|cannot cast %{0 => 2, :x => 5} to :list|
      assert_blame CastError, msg, fn -> cast!(schema, %{0 => 2, :x => 5}) end
    end
  end

  describe "cast!/2 with nested schema" do
    setup do
      %{
        schema: Xema.new({:list, items: {:list, items: {:list, items: [:integer, :string]}}})
      }
    end

    test "from valid data", %{schema: schema} do
      assert cast!(schema, [[[1, "1"], ["2", 2]], [{"3", 3}]]) ==
               [[[1, "1"], [2, "2"]], [[3, "3"]]]
    end

    test "from invalid data", %{schema: schema} do
      msg = ~s|cannot cast "foo" to :integer at [0, 1, 0]|
      assert_blame CastError, msg, fn -> cast!(schema, [[[1, "1"], ["foo", 2]], [{"3", 3}]]) end
    end
  end

  describe "cast/2 with list items (Xema)" do
    setup do
      string = Xema.new(:string)

      %{
        schema: Xema.new({:list, items: string})
      }
    end

    test "return ok tuple for strings", %{schema: schema} do
      assert Xema.cast(schema, ["a", "b"]) == {:ok, ["a", "b"]}
    end

    test "return ok tuple for atoms", %{schema: schema} do
      assert Xema.cast(schema, [:a, :b]) == {:ok, ["a", "b"]}
    end
  end

  describe "cast/2 with list of maps (Xema)" do
    setup do
      %{
        schema:
          Xema.new(
            {:list,
             items: {:map, keys: :strings, properties: %{"a" => :integer, "b" => :integer}}}
          )
      }
    end

    test "return ok tuple for list of maps", %{schema: schema} do
      assert cast(schema, [%{"a" => "1", "b" => "2"}, %{"a" => "3", "b" => "4"}]) ==
               {:ok, [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]}
    end

    test "return ok tuple for list of maps with atom keys", %{schema: schema} do
      assert cast(schema, [%{a: "1", b: "2"}, %{a: "3", b: "4"}]) ==
               {:ok, [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]}
    end

    test "return ok tuple for list encoded as map with correct inner types", %{schema: schema} do
      assert cast(schema, %{"0" => %{"a" => 1, "b" => 2}, "1" => %{"a" => 3, "b" => 4}}) ==
               {:ok, [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]}
    end

    test "return ok tuple for list encoded as map with incorrect inner types", %{schema: schema} do
      assert cast(schema, %{"0" => %{"a" => "1", "b" => "2"}, "1" => %{"a" => "3", "b" => "4"}}) ==
               {:ok, [%{"a" => 1, "b" => 2}, %{"a" => 3, "b" => 4}]}
    end

    test "sorts the list based on key integer values", %{schema: schema} do
      params_list = for i <- 0..50, do: {i, %{"a" => i + 1, "b" => i + 2}}
      expected_sorted_value = Enum.map(params_list, fn {_k, v} -> v end)
      params_map = params_list |> Enum.shuffle() |> Map.new(fn {k, v} -> {to_string(k), v} end)

      assert {:ok, ^expected_sorted_value} = cast(schema, params_map)
    end

    test "returns an error for map non-integer keys", %{schema: schema} do
      params_map = %{
        "0" => %{"a" => 1, "b" => 1},
        "1" => %{"a" => 2, "b" => 2},
        "abc" => %{"a" => 3, "b" => 3},
        ~D[2000-01-01] => %{"a" => 4, "b" => 4}
      }

      assert {:error,
              %Xema.CastError{
                error: nil,
                key: nil,
                message: nil,
                path: [],
                required: nil,
                to: :map,
                value: ^params_map
              }} = cast(schema, params_map)
    end
  end
end
