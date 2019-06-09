defmodule Xema.Cast.OneOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2]

  alias Xema.{CastError, ValidationError}

  describe "cast/2 with one_of schema with types" do
    setup do
      %{
        schema: Xema.new(one_of: [:integer, :string, nil])
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

  describe "cast/2 with one_of schema with properties" do
    setup do
      %{
        schema:
          Xema.new(
            one_of: [
              [properties: %{a: :string}],
              [properties: %{b: :integer}]
            ]
          )
      }
    end

    test "from a map", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, %{a: 1, b: "2"})
      assert error.reason.value == %{a: "1", b: 2}
    end

    test "from a map with an invalid value", %{schema: schema} do
      assert cast(schema, %{a: 1, b: 1.5}) == {:ok, %{a: "1", b: 1.5}}
    end

    test "from a keyword list", %{schema: schema} do
      assert {:error, %ValidationError{} = error} = cast(schema, a: 1, b: "2")
      assert error.reason.value == [a: "1", b: 2]
    end
  end

  describe "cast/2 with one_of schema with multiple properties" do
    setup do
      %{
        schema:
          Xema.new(
            one_of: [
              [properties: %{a: :integer}],
              [properties: %{a: :string}],
              [properties: %{a: nil}]
            ]
          )
      }
    end

    test "from a map with an integer", %{schema: schema} do
      assert cast(schema, %{a: 1}) == {:ok, %{a: 1}}
    end

    test "from a map with an integer string", %{schema: schema} do
      assert cast(schema, %{a: "2"}) == {:ok, %{a: 2}}
    end

    test "from a map with a string", %{schema: schema} do
      assert cast(schema, %{a: "three"}) == {:ok, %{a: "three"}}
    end

    test "from a map with a nil", %{schema: schema} do
      assert cast(schema, %{a: nil}) == {:ok, %{a: nil}}
    end

    test "from a map with an empty list", %{schema: schema} do
      assert {:error, error} = cast(schema, %{a: []})

      assert error ==
               %ValidationError{
                 message: nil,
                 reason: %{
                   one_of:
                     {:error,
                      [
                        %{properties: %{a: %{type: :integer, value: []}}},
                        %{properties: %{a: %{type: :string, value: []}}},
                        %{properties: %{a: %{type: nil, value: []}}}
                      ]},
                   value: %{a: []}
                 }
               }

      message = """
      No match of any schema.
        Expected :integer, got [], at [:a].
        Expected :string, got [], at [:a].
        Expected nil, got [], at [:a].\
      """

      assert Exception.message(error) == message
    end
  end
end
