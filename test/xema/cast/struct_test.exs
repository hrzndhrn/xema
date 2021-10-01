defmodule Xema.Cast.StructTest do
  use ExUnit.Case, async: true

  import AssertBlame
  import Xema, only: [cast: 2, cast!: 2]

  alias Xema.ValidationError
  # A test struct with Xema.Castable protocol implementation
  alias Test.User
  # A test strucht without Xema.Castable protocol implementation
  alias Test.Person

  alias Xema.CastError

  @set [:atom, "str", 1.1, 1, [4], {:tuple}]

  #
  # Xema.cast/2
  #

  describe "cast/2 with a minimal struct schema" do
    setup do
      %{
        schema: Xema.new(:struct)
      }
    end

    test "from an empty map", %{schema: schema} do
      data = %{}

      assert cast(schema, data) ==
               {:error,
                %ValidationError{
                  reason: %{type: :struct, value: %{}}
                }}
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{foo: 6}

      assert cast(schema, data) ==
               {:error,
                %ValidationError{
                  reason: %{type: :struct, value: %{foo: 6}}
                }}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"foo" => 6}

      assert cast(schema, data) ==
               {:error,
                %Xema.ValidationError{
                  reason: %{type: :struct, value: %{"foo" => 6}}
                }}
    end

    test "from a struct with castabel implementation", %{schema: schema} do
      data = %User{name: "Joe", age: 42}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise Protocol.UndefinedError, fn -> cast(schema, %Person{name: "Joe", age: 42}) end
    end

    test "from a keyword list", %{schema: schema} do
      data = [foo: 6]

      assert {:error,
              %CastError{
                key: nil,
                path: [],
                to: :struct,
                value: [foo: 6]
              } = error} = cast(schema, data)

      assert Exception.message(error) == "cannot cast [foo: 6] to :struct"
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: :struct, value: data)}
        assert cast(schema, data) == expected
      end)
    end
  end

  describe "cast/2 with a struct schema" do
    setup do
      %{schema: Xema.new({:struct, module: User})}
    end

    test "from a struct with castable implementation", %{schema: schema} do
      data = %User{name: "Otto", age: 18}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise Protocol.UndefinedError, fn -> cast(schema, %Person{name: "Joe", age: 42}) end
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{name: "Joe", age: 55}
      assert cast(schema, data) == {:ok, %User{name: "Joe", age: 55}}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"name" => "Joe", "age" => 55}
      assert cast(schema, data) == {:ok, %User{name: "Joe", age: 55}}
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 6}

      assert {:error,
              %CastError{
                key: "xyz",
                path: [],
                to: :struct,
                value: nil
              } = error} = cast(schema, data)

      assert Exception.message(error) == ~s|cannot cast "xyz" to :struct key, the atom is unknown|
    end

    test "from a keyword list", %{schema: schema} do
      data = [name: "Joe", age: 55]
      assert cast(schema, data) == {:ok, %User{name: "Joe", age: 55}}
    end

    test "from a keyword list with invalid values", %{schema: schema} do
      data = [name: 55, age: "Joe"]
      assert cast(schema, data) == {:ok, %User{name: 55, age: "Joe"}}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: User, value: data)}
        assert cast(schema, data) == expected
      end)
    end
  end

  describe "cast/2 with a struct schema and properties" do
    setup do
      %{schema: Xema.new({:struct, module: User, properties: %{name: :string, age: :integer}})}
    end

    test "from a struct with castable implementation", %{schema: schema} do
      data = %User{name: "Otto", age: 18}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise Protocol.UndefinedError, fn -> cast(schema, %Person{name: "Joe", age: 42}) end
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{name: "Joe", age: 55}
      assert cast(schema, data) == {:ok, %User{name: "Joe", age: 55}}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"name" => "Joe", "age" => 55}
      assert cast(schema, data) == {:ok, %User{name: "Joe", age: 55}}
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 6}

      assert {:error,
              %Xema.CastError{
                key: "xyz",
                path: [],
                to: :struct,
                value: nil
              } = error} = cast(schema, data)

      assert Exception.message(error) == ~s|cannot cast "xyz" to :struct key, the atom is unknown|
    end

    test "from a keyword list", %{schema: schema} do
      data = [name: "Joe", age: 55]
      assert cast(schema, data) == {:ok, %User{name: "Joe", age: 55}}
    end

    test "from a keyword list with castable values", %{schema: schema} do
      data = [name: 123, age: "55"]
      assert cast(schema, data) == {:ok, %User{name: "123", age: 55}}
    end

    test "from a keyword list with invalid values", %{schema: schema} do
      data = [name: 55, age: "Joe"]

      assert {:error,
              %Xema.CastError{
                key: nil,
                path: [:age],
                to: :integer,
                value: "Joe"
              } = error} = cast(schema, data)

      assert Exception.message(error) == "cannot cast \"Joe\" to :integer at [:age]"
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(path: [], to: User, value: data)}
        assert cast(schema, data) == expected
      end)
    end
  end

  #
  # Xema.cast!/2
  #

  describe "cast!/2 with a minimal struct schema" do
    setup do
      %{
        schema: Xema.new(:struct)
      }
    end

    test "from an empty map", %{schema: schema} do
      data = %{}
      assert_blame ValidationError, "Expected :struct, got %{}.", fn -> cast!(schema, data) end
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{foo: 6}

      assert_blame ValidationError, "Expected :struct, got %{foo: 6}.", fn ->
        cast!(schema, data) == data
      end
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"foo" => 6}

      assert_blame ValidationError, ~s|Expected :struct, got %{"foo" => 6}.|, fn ->
        cast!(schema, data) == data
      end
    end

    test "from a struct with castabel implementation", %{schema: schema} do
      data = %User{name: "Joe", age: 42}
      assert cast!(schema, data) == data
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, %Person{name: "Joe", age: 42})
      end)
    end

    test "from a keyword list", %{schema: schema} do
      data = [foo: 6]
      msg = "cannot cast [foo: 6] to :struct"

      assert_blame(CastError, msg, fn ->
        cast!(schema, data)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :struct"

        assert_blame CastError, msg, fn ->
          cast!(schema, data)
        end
      end)
    end
  end

  describe "cast!/2 with a struct schema" do
    setup do
      %{schema: Xema.new({:struct, module: User})}
    end

    test "from a struct with castable implementation", %{schema: schema} do
      data = %User{name: "Otto", age: 18}
      assert cast!(schema, data) == data
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, %Person{name: "Joe", age: 42})
      end)
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{name: "Joe", age: 55}
      assert cast!(schema, data) == %User{name: "Joe", age: 55}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"name" => "Joe", "age" => 55}
      assert cast!(schema, data) == %User{name: "Joe", age: 55}
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 6}
      msg = ~s|cannot cast "xyz" to :struct key, the atom is unknown|

      assert_blame CastError, msg, fn ->
        cast!(schema, data)
      end
    end

    test "from a keyword list", %{schema: schema} do
      data = [name: "Joe", age: 55]
      assert cast!(schema, data) == %User{name: "Joe", age: 55}
    end

    test "from a keyword list with invalid values", %{schema: schema} do
      data = [name: 55, age: "Joe"]
      assert cast!(schema, data) == %User{name: 55, age: "Joe"}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to Test.User"

        assert_blame CastError, msg, fn ->
          cast!(schema, data)
        end
      end)
    end
  end

  describe "cast!/2 with a struct schema and properties" do
    setup do
      %{
        schema: Xema.new({:struct, module: User, properties: %{name: :string, age: :integer}})
      }
    end

    test "from a struct with castable implementation", %{schema: schema} do
      data = %User{name: "Otto", age: 18}
      assert cast!(schema, data) == data
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast!(schema, %Person{name: "Joe", age: 42})
      end)
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{name: "Joe", age: 55}
      assert cast!(schema, data) == %User{name: "Joe", age: 55}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"name" => "Joe", "age" => 55}
      assert cast!(schema, data) == %User{name: "Joe", age: 55}
    end

    test "from a map with string keys and unknown atom", %{schema: schema} do
      data = %{"xyz" => 6}
      msg = ~s|cannot cast "xyz" to :struct key, the atom is unknown|

      assert_blame CastError, msg, fn ->
        cast!(schema, data)
      end
    end

    test "from a keyword list", %{schema: schema} do
      data = [name: "Joe", age: 55]
      assert cast!(schema, data) == %User{name: "Joe", age: 55}
    end

    test "from a keyword list with castable values", %{schema: schema} do
      data = [name: 123, age: "55"]
      assert cast!(schema, data) == %User{name: "123", age: 55}
    end

    test "from a keyword list with invalid values", %{schema: schema} do
      data = [name: 55, age: "Joe"]
      msg = "cannot cast \"Joe\" to :integer at [:age]"

      assert_blame CastError, msg, fn ->
        cast!(schema, data)
      end
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to Test.User"

        assert_blame CastError, msg, fn ->
          cast!(schema, data)
        end
      end)
    end
  end

  describe "cast!/2 with a struct schema and required property" do
    setup do
      %{
        schema:
          Xema.new({
            :struct,
            module: User, properties: %{name: :string, age: :integer}, required: [:name]
          })
      }
    end

    test "from a keyword list", %{schema: schema} do
      name = "Otto"
      age = 18

      assert cast!(schema, name: name, age: age) == %User{name: name, age: age}
    end

    test "from a map with string keys", %{schema: schema} do
      name = "Otto"
      age = 18

      assert cast!(schema, %{"name" => name, "age" => age}) == %User{name: name, age: age}
    end
  end
end
