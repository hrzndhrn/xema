defmodule Xema.Cast.StructTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 2, cast!: 2]

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
      assert cast(schema, data) == {:ok, data}
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{foo: 6}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"foo" => 6}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a struct with castabel implementation", %{schema: schema} do
      data = %User{name: "Joe", age: 42}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast(schema, %Person{name: "Joe", age: 42})
      end)
    end

    test "from a keyword list", %{schema: schema} do
      data = [foo: 6]

      assert cast(schema, data) ==
               {:error,
                %CastError{
                  key: nil,
                  message: "cannot cast [foo: 6] to :struct",
                  path: [],
                  to: :struct,
                  value: [foo: 6]
                }}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :struct, value: data})}
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
      assert_raise(Protocol.UndefinedError, fn ->
        cast(schema, %Person{name: "Joe", age: 42})
      end)
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

      assert cast(schema, data) ==
               {:error,
                %Xema.CastError{
                  key: "xyz",
                  message: ~s|cannot cast "xyz" to :struct key, the atom is unknown|,
                  path: [],
                  to: :struct,
                  value: nil
                }}
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
        expected = {:error, CastError.exception(%{path: [], to: :struct, value: data})}
        assert cast(schema, data) == expected
      end)
    end
  end

  describe "cast/2 with a struct schema and properties" do
    setup do
      %{
        schema: Xema.new({:struct, module: User, properties: %{name: :string, age: :integer}})
      }
    end

    test "from a struct with castable implementation", %{schema: schema} do
      data = %User{name: "Otto", age: 18}
      assert cast(schema, data) == {:ok, data}
    end

    test "from a struct without castable implementation", %{schema: schema} do
      assert_raise(Protocol.UndefinedError, fn ->
        cast(schema, %Person{name: "Joe", age: 42})
      end)
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

      assert cast(schema, data) ==
               {:error,
                %Xema.CastError{
                  key: "xyz",
                  message: ~s|cannot cast "xyz" to :struct key, the atom is unknown|,
                  path: [],
                  to: :struct,
                  value: nil
                }}
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

      assert cast(schema, data) ==
               {:error,
                %Xema.CastError{
                  key: nil,
                  message: "cannot cast \"Joe\" to :integer at [:age]",
                  path: [:age],
                  to: :integer,
                  value: "Joe"
                }}
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        expected = {:error, CastError.exception(%{path: [], to: :struct, value: data})}
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
      assert cast!(schema, data) == data
    end

    test "from a map with atom keys", %{schema: schema} do
      data = %{foo: 6}
      assert cast!(schema, data) == data
    end

    test "from a map with string keys", %{schema: schema} do
      data = %{"foo" => 6}
      assert cast!(schema, data) == data
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

      assert_raise(CastError, msg, fn ->
        cast!(schema, data)
      end)
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :struct"

        assert_raise CastError, msg, fn ->
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

      assert_raise CastError, msg, fn ->
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
        msg = "cannot cast #{inspect(data)} to :struct"

        assert_raise CastError, msg, fn ->
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

      assert_raise CastError, msg, fn ->
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

      assert_raise CastError, msg, fn ->
        cast!(schema, data)
      end
    end

    test "from an invalid type", %{schema: schema} do
      Enum.each(@set, fn data ->
        msg = "cannot cast #{inspect(data)} to :struct"

        assert_raise CastError, msg, fn ->
          cast!(schema, data)
        end
      end)
    end
  end
end
