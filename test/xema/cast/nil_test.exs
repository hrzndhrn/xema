defmodule Xema.Cast.NilTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import AssertBlame
  import Xema, only: [cast: 2, cast!: 2]

  describe "nil schema" do
    setup do
      %{
        schema: Xema.new(nil),
        set: [:atom, "str", 1.1, 1, [], %{}, {:tuple}]
      }
    end

    test "cast/2", %{schema: schema} do
      assert cast(schema, nil) == {:ok, nil}
    end

    test "cast/2 with invalid value", %{schema: schema, set: set} do
      Enum.each(set, fn data ->
        expected = {:error, CastError.exception(path: [], to: nil, value: data)}

        assert cast(schema, data) == expected
      end)
    end

    test "cast/2 with an invalid type", %{schema: schema} do
      assert {:error, %Protocol.UndefinedError{}} = cast(schema, ~r/.*/)
    end

    test "cast!/2", %{schema: schema} do
      assert cast!(schema, nil) == nil
    end

    test "cast!/2 with invalid value", %{schema: schema, set: set} do
      Enum.each(set, fn data ->
        msg = "cannot cast #{inspect(data)} to nil"

        assert_blame CastError, msg, fn ->
          cast!(schema, data) == data
        end
      end)
    end

    test "cast!/2 with an invalid type", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end
  end
end
