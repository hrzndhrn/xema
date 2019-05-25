defmodule Xema.AccessTest do
  use ExUnit.Case

  import AssertBlame

  # The tests are all calling the functions in `Xema` that are delegate or call the funcitons
  # in `Xema.Access`.

  alias Xema.PathError
  alias Xema.ValidationError

  @users [
    %{
      name: "John",
      age: 45
    },
    %{
      name: "Nick",
      age: 21
    }
  ]

  @data %{
    "users" => @users,
    "tuple" => {
      72,
      [a: 1, b: 2]
    },
    "list" => [?a, ?b, ?c]
  }

  @users_schema Xema.new(
                  {:list,
                   items:
                     {:map,
                      properties: %{
                        name: :string,
                        age: {:integer, minimum: 0}
                      }}}
                )

  describe "get2/" do
    test "returns a value for a valid path" do
      assert Xema.get(@data, ["users", 0, :age]) == 45
      assert Xema.get(@data, ["users", -1, :age]) == 21
      assert Xema.get(@data, ["tuple", 1, :a]) == 1
      assert Xema.get(@data, ["tuple", 1, 1]) == {:b, 2}
      assert Xema.get(@data, ["list", 1]) == ?b
    end

    test "returns nil for invalid path" do
      assert Xema.get(@data, ["users", 0, :foo]) == nil
      assert Xema.get(@data, [1, 0, :foo]) == nil
      assert Xema.get(@data, ["users", 10, :age]) == nil
      assert Xema.get(@data, ["account", 0, :age]) == nil
      assert Xema.get(@data, [:user, 0, :age]) == nil
      assert Xema.get(@data, ["users", :foo, :age]) == nil
    end

    test "raises an ArgumentError for invalid list index" do
      assert_raise ArgumentError, fn -> Xema.get(@data, ["users", "0", :age]) == nil end
    end

    test "returns a list with Access.all/0 in path" do
      assert Xema.get(@data, ["users", Access.all(), :name]) == ["John", "Nick"]
    end
  end

  describe "get/3" do
    test "returns a value for a valid path" do
      assert Xema.get(@users_schema, @users, [0, :age]) == 45
    end

    test "returns nil for invalid data" do
      data = Enum.concat(@users, [%{name: "Tim", age: -3}])
      assert Xema.get(@users_schema, data, [0, :age]) == nil
    end
  end

  describe "fetch/2" do
    test "returns a value for a valid path" do
      assert Xema.fetch(@data, ["users", 0, :age]) == {:ok, 45}
      assert Xema.fetch(@data, ["users", -1, :age]) == {:ok, 21}
      assert Xema.fetch(@data, ["tuple", 1, :a]) == {:ok, 1}
      assert Xema.fetch(@data, ["tuple", 1, 1]) == {:ok, {:b, 2}}
      assert Xema.fetch(@data, ["list", 1]) == {:ok, ?b}
    end

    test "returns a error tuple for invalid path" do
      assert {:error, %PathError{}} = Xema.fetch(@data, ["users", 0, :foo])
    end

    test "raises an ArgumentError for invalid list index" do
      assert_raise ArgumentError, fn -> Xema.fetch(@data, ["users", "0", :age]) == nil end
    end
  end

  describe "fetch/3" do
    test "returns a value in an ok tuple for a valid path" do
      assert Xema.fetch(@users_schema, @users, [0, :age]) == {:ok, 45}
    end

    test "returns an error tuple for invalid data" do
      data = Enum.concat(@users, [%{name: "Tim", age: -3}])

      assert Xema.fetch(@users_schema, data, [0, :age]) ==
               {:error,
                %ValidationError{
                  reason: %{
                    items: [{2, %{properties: %{age: %{minimum: 0, value: -3}}}}]
                  }
                }}
    end
  end

  describe "fetch!/2" do
    test "returns a value for a valid path" do
      assert Xema.fetch!(@data, ["users", 0, :age]) == 45
      assert Xema.fetch!(@data, ["users", -1, :age]) == 21
      assert Xema.fetch!(@data, ["tuple", 1, :a]) == 1
      assert Xema.fetch!(@data, ["tuple", 1, 1]) == {:b, 2}
    end

    @tag :only
    test "raise an error for invalid path" do
      message = ~s|path [\"users\", 0, :foo] not found in: #{inspect(@data)}|
      assert_blame PathError, message, fn -> Xema.fetch!(@data, ["users", 0, :foo]) end
    end
  end

  describe "fetch!/3" do
    test "returns a value for a valid path" do
      assert Xema.fetch!(@users_schema, @users, [0, :age]) == 45
    end

    test "raise an error for invalid data" do
      data = Enum.concat(@users, [%{name: "Tim", age: -3}])
      message = "Value -3 is less than minimum value of 0, at [2, :age]."
      assert_blame ValidationError, message, fn -> Xema.fetch!(@users_schema, data, [0, :age]) end
    end
  end
end
