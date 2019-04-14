defmodule Xema.Cast.AnyTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, cast!: 2]

  describe "any schema" do
    setup do
      %{
        schema: Xema.new(:any),
        set: [:atom, "str", 1.1, 1, [], %{}, {:a, "a"}, {:tuple}]
      }
    end

    test "cast/2", %{schema: schema, set: set} do
      Enum.each(set, fn data ->
        assert cast(schema, data) == {:ok, data}
      end)
    end

    test "cast/2 with an invalid type", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast(schema, ~r/.*/)
      end)
    end

    test "cast!/2", %{schema: schema, set: set} do
      Enum.each(set, fn data ->
        assert cast!(schema, data) == data
      end)
    end

    test "cast!/2 with an invalid type", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end
  end
end
