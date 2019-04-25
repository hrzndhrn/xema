defmodule Xema.Cast.AtomTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  @set [42, 1.0, [foo: 42], [42], %{}, {:tuple}]

  describe "cast/2 with a minimal integer schema" do
    setup do
      %{
        schema: Xema.new(:atom)
      }
    end

    test "from an atom", %{schema: schema} do
      data = :foo

      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a string", %{schema: schema} do
      data = "foo"

      assert {:error, %{type: :atom, value: "foo"}} = validate(schema, data)
      assert cast(schema, data) == {:ok, :foo}
    end

    test "from an invalid string", %{schema: schema} do
      data = "xyz"
      expected = {:error, CastError.exception(%{path: [], to: :atom, value: "xyz"})}

      assert cast(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :atom, value: data})}

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
        schema: Xema.new(:atom)
      }
    end

    test "from an atom", %{schema: schema} do
      assert cast!(schema, :foo) == :foo
    end

    test "from a string", %{schema: schema} do
      assert cast!(schema, "foo") == :foo
    end

    test "from an invalid string", %{schema: schema} do
      msg = ~s|cannot cast "xyz" to :atom, the atom is unknown|

      assert_raise CastError, msg, fn ->
        cast!(schema, "xyz")
      end
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :atom"

        assert_raise CastError, msg, fn -> cast!(schema, data) end
      end)
    end
  end
end
