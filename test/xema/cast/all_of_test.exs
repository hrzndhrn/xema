defmodule Xema.Cast.AllOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2]

  alias Xema.{CastError, ValidationError}

  describe "cast/2 with all_of schema with types" do
    setup do
      %{
        schema: Xema.new(all_of: [:integer, :string, nil])
      }
    end

    test "from an integer", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, 6)
      assert error.reason.value == 6
    end

    test "from an integer string", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, "9")
      assert error.reason.value == 9
    end

    test "from a string", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, "nine")
      assert error.reason.value == "nine"
    end

    test "from a nil", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, nil)
      assert error.reason.value == nil
    end

    test "from a float", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, 5.5)
      assert error.reason.value == "5.5"
    end

    test "from an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, [])
      assert error == %CastError{path: [], to: [:integer, :string, nil], value: []}
      assert Exception.message(error) == "cannot cast [] to any of [:integer, :string, nil]"
    end
  end

  describe "cast/2 with all_of schema with properties" do
    setup do
      %{
        schema:
          Xema.new(
            all_of: [
              [properties: %{a: :string}],
              [properties: %{b: :integer}]
            ]
          )
      }
    end

    test "from a map", %{schema: schema} do
      assert cast(schema, %{a: 1, b: "2"}) == {:ok, %{a: "1", b: 2}}
    end

    test "from a map with an invalid value", %{schema: schema} do
      assert {:error, error} = cast(schema, %{a: 1, b: 1.5})
      assert error == %Xema.CastError{path: [:b], to: :integer, value: 1.5}
      assert Exception.message(error) == "cannot cast 1.5 to :integer at [:b]"
    end

    test "from a keyword list", %{schema: schema} do
      assert cast(schema, a: 1, b: "2") == {:ok, [a: "1", b: 2]}
    end
  end

  describe "cast/2 with all_of schema with multiple properties" do
    setup do
      %{
        schema:
          Xema.new(
            all_of: [
              [properties: %{a: :integer}],
              [properties: %{a: :string}],
              [properties: %{a: nil}]
            ]
          )
      }
    end

    test "from a map with an integer", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, %{a: 1})
      assert error.reason.value == %{a: 1}
    end

    test "from a map with an integer string", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, %{a: "2"})
      assert error.reason.value == %{a: 2}
    end

    test "from a map with a string", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, %{a: "three"})
      assert error.reason.value == %{a: "three"}
    end

    test "from a map with a nil", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, %{a: nil})
      assert error.reason.value == %{a: nil}
    end

    test "from a map with an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, %{a: []})
      assert error == %CastError{path: [:a], to: [:integer, :string, nil], value: []}

      assert Exception.message(error) ==
               "cannot cast [] to any of [:integer, :string, nil] at [:a]"
    end
  end
end
