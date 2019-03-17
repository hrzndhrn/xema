defmodule Xema.CastMapTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, validate: 2]

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
      assert validate(schema, data) == {:error, %{type: :integer, value: "42"}}
      assert cast(schema, data) == {:ok, 42}
    end

    test "from an invalid string", %{schema: schema} do
      assert cast(schema, "66.6") == {:error, :not_an_integer}
    end

    test "from an invalid type", %{schema: schema} do
    end
  end
end
