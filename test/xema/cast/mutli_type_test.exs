defmodule Xema.Cast.MultiTypeTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2]

  alias Xema.CastError

  describe "cast/2 with multi type schema" do
    setup do
      %{
        schema: Xema.new([:integer, :string, nil])
      }
    end

    test "from an integer", %{schema: schema} do
      assert cast(schema, 6) == {:ok, 6}
    end

    test "from an integer string", %{schema: schema} do
      assert cast(schema, "9") == {:ok, 9}
    end

    test "from a string", %{schema: schema} do
      assert cast(schema, "nine") == {:ok, "nine"}
    end

    test "from a nil", %{schema: schema} do
      assert cast(schema, nil) == {:ok, nil}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, 5.5) == {:ok, "5.5"}
    end

    test "from an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, [])
      assert error == %CastError{path: [], to: [:integer, :string, nil], value: []}
      assert Exception.message(error) == "cannot cast [] to any of [:integer, :string, nil]"
    end
  end

  describe "cast/2 with multi type for a property" do
    setup do
      %{
        schema: Xema.new(properties: %{a: [:integer, :string, nil]})
      }
    end

    test "from an integer", %{schema: schema} do
      assert cast(schema, %{a: 6}) == {:ok, %{a: 6}}
    end

    test "from an integer string", %{schema: schema} do
      assert cast(schema, %{a: "9"}) == {:ok, %{a: 9}}
    end

    test "from a string", %{schema: schema} do
      assert cast(schema, %{a: "nine"}) == {:ok, %{a: "nine"}}
    end

    test "from a nil", %{schema: schema} do
      assert cast(schema, %{a: nil}) == {:ok, %{a: nil}}
    end

    test "from a float", %{schema: schema} do
      assert cast(schema, %{a: 5.5}) == {:ok, %{a: "5.5"}}
    end

    test "from an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, %{a: []})
      assert error == %CastError{path: [:a], to: [:integer, :string, nil], value: []}

      assert Exception.message(error) ==
               "cannot cast [] to any of [:integer, :string, nil] at [:a]"
    end
  end
end
