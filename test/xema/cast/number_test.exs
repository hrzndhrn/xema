defmodule Xema.Cast.NumberTest do
  use ExUnit.Case, async: true

  alias Xema.{CastError, ValidationError}

  import AssertBlame
  import Xema, only: [cast: 2, cast!: 2, validate: 2]

  @set [:foo, "foo", [foo: 42], [42], %{}, {:tuple}]

  describe "cast/2 with a minimal integer schema" do
    setup do
      %{
        schema: Xema.new(:number)
      }
    end

    test "from an integer", %{schema: schema} do
      data = 42
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from a float", %{schema: schema} do
      data = 42.24
      assert validate(schema, data) == :ok
      assert cast(schema, data) == {:ok, data}
    end

    test "from an integer string", %{schema: schema} do
      data = "42"

      assert {:error,
              %ValidationError{
                reason: %{
                  type: :number,
                  value: ^data
                }
              }} = validate(schema, data)

      assert cast(schema, data) == {:ok, 42}
    end

    test "from a float string", %{schema: schema} do
      data = "42.24"

      assert {:error,
              %ValidationError{
                reason: %{
                  type: :number,
                  value: "42.24"
                }
              }} = validate(schema, data)

      assert cast(schema, data) == {:ok, 42.24}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: :number, value: data)}

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
        schema: Xema.new(:number)
      }
    end

    test "from an integer", %{schema: schema} do
      assert cast!(schema, 42) == 42
    end

    test "from a float", %{schema: schema} do
      assert cast!(schema, 42.11) == 42.11
    end

    test "from an integer string", %{schema: schema} do
      assert cast!(schema, "44") == 44
    end

    test "from a float string", %{schema: schema} do
      assert cast!(schema, "44.55") == 44.55
    end

    test "from a type without protocol implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, ~r/.*/)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :number"

        assert_blame CastError, msg, fn -> cast!(schema, data) end
      end)
    end
  end
end
