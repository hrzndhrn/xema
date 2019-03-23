defmodule Xema.Cast.AtomTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, validate: 2]

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
      assert validate(schema, data) == {:error, %{type: :atom, value: "foo"}}
      assert cast(schema, data) == {:ok, :foo}
    end

    test "from an invalid string", %{schema: schema} do
      assert cast(schema, "xyz") ==
               {:error, %{path: [], reason: {:unknown_atom, "xyz"}}}
    end

    test "from an invalid type", %{schema: schema} do
      assert cast(schema, 42) ==
               {:error, %{path: [], reason: %{cast: Integer, to: :atom}}}

      assert cast(schema, 1.0) ==
               {:error, %{path: [], reason: %{cast: Float, to: :atom}}}

      assert cast(schema, foo: 42) ==
               {:error, %{path: [], reason: %{cast: Keyword, to: :atom}}}

      assert cast(schema, [42]) ==
               {:error, %{path: [], reason: %{cast: List, to: :atom}}}

      assert cast(schema, %{}) ==
               {:error, %{path: [], reason: %{cast: Map, to: :atom}}}
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast(schema, ~r/.*/)
      end)
    end
  end
end
