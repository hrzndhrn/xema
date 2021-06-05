defmodule Xema.Cast.TimeTest do
  use ExUnit.Case, async: true

  alias Xema.CastError

  import Xema, only: [cast: 2, cast!: 2]

  @set [:foo, 1, 1.0, [42], {:tuple}]

  describe "cast/2 with a time schema" do
    setup do
      %{schema: Xema.new({:struct, module: Time})}
    end

    test "from a time", %{schema: schema} do
      time = Time.utc_now()

      assert cast(schema, time) == {:ok, time}
    end

    test "from a valid string", %{schema: schema} do
      time = Time.utc_now()
      data = Time.to_iso8601(time)

      assert cast(schema, data) == {:ok, time}
    end

    test "from an invalid string", %{schema: schema} do
      data = "today"
      expected = {:error, CastError.exception(path: [], to: Time, value: "today")}

      assert cast(schema, data) == expected
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: Time, value: data)}

        assert cast(schema, data) == expected
      end)
    end

    test "reaturns an error tuple for a keyword list", %{schema: schema} do
      assert {:error, error} = cast(schema, foo: 55)

      assert Exception.message(error) ==
               "cannot cast [foo: 55] to Time, key :foo not found in Time"

      assert error == %CastError{
               key: :foo,
               message: nil,
               path: [],
               to: Time,
               value: [foo: 55]
             }
    end

    test "raises an error for a map", %{schema: schema} do
      assert {:error, error} = cast(schema, %{foo: 55})

      assert Exception.message(error) ==
               "cannot cast %{foo: 55} to Time, key :foo not found in Time"
    end

    test "returns an error tuple for an empty map", %{schema: schema} do
      assert {:error, error} = cast(schema, %{})

      assert Exception.message(error) ==
               "cannot cast %{} to Time, the following keys must also be given when " <>
                 "building struct Time: [:hour, :minute, :second]"
    end
  end

  describe "cast!/2 with a time schema" do
    setup do
      %{schema: Xema.new({:struct, module: Time})}
    end

    test "from a valid string", %{schema: schema} do
      time = Time.utc_now()
      data = Time.to_iso8601(time)

      assert cast!(schema, data) == time
    end

    test "from an invalid string", %{schema: schema} do
      assert_raise CastError, fn -> cast!(schema, "today") end
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        assert_raise CastError, fn -> cast!(schema, data) end
      end)
    end

    test "raises an error for a keyword list", %{schema: schema} do
      assert_raise CastError, fn -> cast!(schema, foo: 55) end
    end

    test "raises an error for a map", %{schema: schema} do
      assert_raise CastError, fn -> cast!(schema, %{foo: 55}) end
    end

    test "raises an error for an empty map", %{schema: schema} do
      assert_raise CastError, fn -> cast!(schema, %{}) end
    end
  end

  describe "cast/2 without a naive date-time schema" do
    test "raises an error for a naive date-time schema" do
      schema = Xema.new({:struct, module: Regex})
      assert {:error, error} = cast(schema, ~T[15:07:58])

      assert error == %Xema.CastError{
               path: [],
               to: Regex,
               value: ~T[15:07:58]
             }
    end

    test "raises an error for an integer schema" do
      schema = Xema.new(:integer)
      assert {:error, error} = cast(schema, ~T[15:07:58])

      assert error == %Xema.CastError{
               path: [],
               to: :integer,
               value: ~T[15:07:58]
             }
    end
  end
end
