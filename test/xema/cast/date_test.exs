defmodule Xema.Cast.DateTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import AssertBlame
  import Xema, only: [cast: 2, cast!: 2]

  @set [:foo, 1, 1.0, [42], {:tuple}]

  describe "cast/2 with a date schema" do
    setup do
      %{schema: Xema.new({:struct, module: Date})}
    end

    test "from a date", %{schema: schema} do
      date = Date.utc_today()

      assert cast(schema, date) == {:ok, date}
    end

    test "from a valid string", %{schema: schema} do
      date = Date.utc_today()
      data = Date.to_iso8601(date)

      assert cast(schema, data) == {:ok, date}
    end

    test "from an invalid string", %{schema: schema} do
      data = "today"
      expected = {:error, CastError.exception(path: [], to: Date, value: "today")}

      assert cast(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: Date, value: data)}

        assert cast(schema, data) == expected
      end)
    end

    test "raises an error for a keyword list", %{schema: schema} do
      assert {:error, %KeyError{}} = cast(schema, foo: 55)
    end

    test "raises an error for a map", %{schema: schema} do
      assert {:error, %KeyError{}} = cast(schema, %{foo: 55})
    end

    test "raises an error for an empty map", %{schema: schema} do
      assert {:error, %ArgumentError{}} = cast(schema, %{})
    end
  end

  describe "cast!/2 with a date schema" do
    setup do
      %{schema: Xema.new({:struct, module: Date})}
    end

    test "from a valid string", %{schema: schema} do
      date = Date.utc_today()
      data = Date.to_iso8601(date)

      assert cast!(schema, data) == date
    end

    test "from an invalid string", %{schema: schema} do
      assert_blame CastError, fn -> cast!(schema, "today") end
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        assert_blame CastError, fn -> cast!(schema, data) end
      end)
    end

    test "raises an error for a keyword list", %{schema: schema} do
      assert_raise KeyError, fn -> cast!(schema, foo: 55) end
    end

    test "raises an error for a map", %{schema: schema} do
      assert_raise KeyError, fn -> cast!(schema, %{foo: 55}) end
    end

    test "raises an error for an empty map", %{schema: schema} do
      assert_raise ArgumentError, fn -> cast!(schema, %{}) end
    end
  end
end
