defmodule Xema.Cast.BooleanTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import AssertBlame
  import Xema, only: [cast: 2, cast!: 2]

  @set [:foo, 1, 1.0, [42], [foo: 42], %{}, {:tuple}, "foo"]

  describe "cast/2 with a minimal boolean schema" do
    setup do
      %{
        schema: Xema.new(:boolean)
      }
    end

    test "from a boolean", %{schema: schema} do
      assert cast(schema, true) == {:ok, true}
      assert cast(schema, false) == {:ok, false}
    end

    test "from a string containing a boolean", %{schema: schema} do
      assert cast(schema, "true") == {:ok, true}
      assert cast(schema, "false") == {:ok, false}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: :boolean, value: data)}

        assert cast(schema, data) == expected
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise Protocol.UndefinedError, fn -> cast(schema, ~r/.*/) end
    end
  end

  describe "cast!/2 with a minimal boolean schema" do
    setup do
      %{
        schema: Xema.new(:boolean)
      }
    end

    test "from a boolean", %{schema: schema} do
      assert cast!(schema, true) == true
      assert cast!(schema, false) == false
    end

    test "from a string containing a boolean", %{schema: schema} do
      assert cast!(schema, "true") == {:ok, true}
      assert cast!(schema, "false") == {:ok, false}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect data} to :boolean"

        assert_blame CastError, msg, fn -> cast!(schema, data) end
      end)
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise Protocol.UndefinedError, fn -> cast!(schema, ~r/.*/) end
    end
  end
end
