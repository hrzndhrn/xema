defmodule Xema.Cast.ListTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  alias Xema.CastError

  @set [:atom, "str", 1.1, 1, %{}, [a: 1]]

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
      assert {:error, %{type: :list, value: data}} = validate(schema, data)
      assert cast(schema, data) == {:ok, expected}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :list, value: data})}

        assert cast(schema, data) == expected
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert {:error, %Protocol.UndefinedError{}} = cast(schema, ~r/.*/)
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
      expected = {:error, CastError.exception(%{path: [2], to: :integer, value: "foo"})}

      assert cast(schema, data) == expected
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
      expected = {:error, CastError.exception(%{path: [0], to: :integer, value: "foo"})}

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
      data = {"foo", 2}
      expected = {:error, CastError.exception(%{path: [0], to: :integer, value: "foo"})}

      assert cast(schema, data) == expected
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
      expected = {:error, CastError.exception(%{path: [0, 1, 0], to: :integer, value: "foo"})}

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
      assert {:error, %{type: :list, value: data}} = validate(schema, data)
      assert cast!(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :list"

        assert_raise CastError, msg, fn -> cast!(schema, data) end
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
      assert_raise CastError, msg, fn -> cast!(schema, ["1", "2", "foo"]) end
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
      assert_raise CastError, msg, fn -> cast!(schema, ["foo", 2]) end
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
      assert_raise CastError, msg, fn -> cast!(schema, {"foo", 2}) end
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
      assert_raise CastError, msg, fn -> cast!(schema, [[[1, "1"], ["foo", 2]], [{"3", 3}]]) end
    end
  end
end
