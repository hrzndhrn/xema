defmodule Xema.Cast.DecimalTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import Xema, only: [cast: 2, cast!: 2]

  @set [:foo, [42], {:tuple}]

  describe "cast/2 with a time schema" do
    setup do
      %{schema: Xema.new({:struct, module: Decimal})}
    end

    test "from a decimal", %{schema: schema} do
      data = Decimal.from_float(55.5)

      assert cast(schema, data) == {:ok, data}
    end

    test "from a valid string", %{schema: schema} do
      assert cast(schema, "45.6") == {:ok, Decimal.from_float(45.6)}
    end

    test "from an invalid string", %{schema: schema} do
      assert cast(schema, "4/5") ==
               {:error, CastError.exception(path: [], to: Decimal, value: "4/5")}
    end

    test "from an integer", %{schema: schema} do
      assert cast(schema, 45) == {:ok, Decimal.new(45)}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 4.5) == {:ok, Decimal.from_float(4.5)}
    end

    test "raises an error for a map", %{schema: schema} do
      assert {:error, error} = cast(schema, %{foo: 55})

      assert Exception.message(error) ==
               "cannot cast %{foo: 55} to Decimal, key :foo not found in Decimal"
    end

    test "raises an error for a keyword list", %{schema: schema} do
      assert {:error, error} = cast(schema, foo: 55)

      assert Exception.message(error) ==
               "cannot cast [foo: 55] to Decimal, key :foo not found in Decimal"
    end

    test "return a Decimal<0> for an empty map", %{schema: schema} do
      assert cast(schema, %{}) == {:ok, Decimal.new(0)}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: Decimal, value: data)}

        assert cast(schema, data) == expected
      end)
    end
  end

  describe "cast!/2 with a time schema" do
    setup do
      %{schema: Xema.new({:struct, module: Decimal})}
    end

    test "from a valid string", %{schema: schema} do
      assert cast!(schema, "45.6") == Decimal.from_float(45.6)
    end

    test "from an invalid string", %{schema: schema} do
      assert_raise CastError, fn -> assert cast!(schema, "4/5") end
    end

    test "from an integer", %{schema: schema} do
      assert cast!(schema, 45) == Decimal.new(45)
    end

    test "from a float", %{schema: schema} do
      assert cast!(schema, 4.5) == Decimal.from_float(4.5)
    end

    test "raises an error for a map", %{schema: schema} do
      assert_raise CastError, fn -> cast!(schema, %{foo: 55}) end
    end

    test "raises an error for a keyword list", %{schema: schema} do
      assert_raise CastError, fn -> cast!(schema, foo: 55) end
    end

    test "return a Decimal<0> for an empty map", %{schema: schema} do
      assert cast!(schema, %{}) == Decimal.new(0)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        assert_raise CastError, fn -> cast!(schema, data) end
      end)
    end
  end
end
