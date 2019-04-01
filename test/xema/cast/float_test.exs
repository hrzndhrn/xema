defmodule Xema.Cast.FloatTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  @set [55, [55], [num: 55], :foo, %{}, {:tuplt}]

  describe "cast/2 with a minimal integer schema" do
    setup do
      %{
        schema: Xema.new(:float)
      }
    end

    test "from a float", %{schema: schema} do
      data = 42.0
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a string", %{schema: schema} do
      data = "42.6"
      assert validate(schema, data) == {:error, %{type: :float, value: "42.6"}}
      assert cast(schema, data) == {:ok, 42.6}
    end

    test "from an invalid string", %{schema: schema} do
      data = "66,6"
      expected = {:error, CastError.exception(%{path: [], to: :float, value: "66,6"})}

      assert cast(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :float, value: data})}

        assert cast(schema, data) == expected
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast(schema, ~r/.*/)
      end)
    end
  end

  describe "cast!/2 with a minimal integer schema" do
    setup do
      %{
        schema: Xema.new(:float)
      }
    end

    test "from a float", %{schema: schema} do
      assert cast!(schema, 42.7) == 42.7
    end

    test "from a string", %{schema: schema} do
      assert cast!(schema, 24.5) == 24.5
    end

    test "from an invalid string", %{schema: schema} do
      assert_raise_cast_error(schema, "66,6")
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data -> assert_raise_cast_error(schema, data) end)
    end

    defp assert_raise_cast_error(schema, data) do
      msg = "cannot cast #{inspect(data)} to :float"

      assert_raise CastError, msg, fn ->
        cast!(schema, data)
      end
    end
  end
end
