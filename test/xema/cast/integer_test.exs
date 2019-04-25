defmodule Xema.Cast.IntegerTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  @set [:foo, 1.0, [foo: 42], [42], %{}, {:tuple}]

  describe "cast/2 with a minimal integer schema" do
    setup do
      %{
        schema: Xema.new(:integer)
      }
    end

    test "from an integer", %{schema: schema} do
      data = 42

      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a string", %{schema: schema} do
      data = "42"

      assert {:error, %{type: :integer, value: "42"}} = validate(schema, data)
      assert cast(schema, data) == {:ok, 42}
    end

    test "from an invalid string", %{schema: schema} do
      data = "66.6"
      expected = {:error, CastError.exception(%{path: [], to: :integer, value: "66.6"})}

      assert cast(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :integer, value: data})}

        assert cast(schema, data) == expected
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert {:error, %Protocol.UndefinedError{}} = cast(schema, ~r/.*/)
    end
  end

  describe "cast!/2 with a minimal integer schema" do
    setup do
      %{
        schema: Xema.new(:integer)
      }
    end

    test "from an integer", %{schema: schema} do
      assert cast!(schema, 42) == 42
    end

    test "from a string", %{schema: schema} do
      assert cast!(schema, "44") == 44
    end

    test "from an invalid string", %{schema: schema} do
      data = "66.6"
      msg = "cannot cast #{inspect(data)} to :integer"

      assert_raise CastError, msg, fn -> cast!(schema, data) end
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :integer"

        assert_raise CastError, msg, fn -> cast!(schema, data) end
      end)
    end
  end
end
