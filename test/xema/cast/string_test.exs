defmodule Xema.Cast.StringTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  @set [[42], [foo: 42], %{}, {:tuple}]
  describe "cast/2 with a minimal integer schema" do
    setup do
      %{
        schema: Xema.new(:string)
      }
    end

    test "from a string", %{schema: schema} do
      data = "foo"
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from an integer", %{schema: schema} do
      assert cast(schema, 42) == {:ok, "42"}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 1.2) == {:ok, "1.2"}
    end

    test "from an atom", %{schema: schema} do
      assert cast(schema, :foo) == {:ok, "foo"}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :string, value: data})}
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
        schema: Xema.new(:string)
      }
    end

    test "from a string", %{schema: schema} do
      assert cast!(schema, "string") == "string"
    end

    test "from an integer", %{schema: schema} do
      assert cast!(schema, 42) == "42"
    end

    test "from a float", %{schema: schema} do
      assert cast!(schema, 42.11) == "42.11"
    end

    test "from an atom", %{schema: schema} do
      assert cast!(schema, :foo) == "foo"
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :string"

        assert_raise CastError, msg, fn -> cast!(schema, data) end
      end)
    end
  end
end
