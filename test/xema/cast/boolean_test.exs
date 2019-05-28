defmodule Xema.Cast.BooleanTest do
  use ExUnit.Case, async: true

  alias Xema.{CastError, ValidationError}

  import AssertBlame
  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  @set [:foo, 1, 1.0, [42], [foo: 42], %{}, {:tuple}]

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

    test "from a string", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  type: :boolean,
                  value: "true"
                }
              }} = validate(schema, "true")
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: :boolean, value: data)}

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
        schema: Xema.new(:boolean)
      }
    end

    test "from a boolean", %{schema: schema} do
      assert cast!(schema, true) == true
      assert cast!(schema, false) == false
    end

    test "from a string", %{schema: schema} do
      data = "true"
      msg = "cannot cast #{inspect(data)} to :boolean"

      assert_blame CastError, msg, fn -> cast!(schema, data) end
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :boolean"

        assert_blame CastError, msg, fn -> cast!(schema, data) end
      end)
    end
  end
end
