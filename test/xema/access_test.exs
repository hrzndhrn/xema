defmodule Xema.AccessTest do
  use ExUnit.Case

  # The tests are all calling the functions in `Xema` that are delegate or call the funcitons
  # in `Xema.Access`.

  alias Xema.PathError

  @data %{
    "users" => [
      %{
        name: "John",
        age: 45
      },
      %{
        name: "Nick",
        age: 21
      }
    ],
    "tuple" => {
      72,
      [a: 1, b: 2]
    }
  }

  describe "get2/" do
    test "returns a value for a valid path" do
      assert Xema.get(@data, ["users", 0, :age]) == 45
      assert Xema.get(@data, ["users", -1, :age]) == 21
      assert Xema.get(@data, ["tuple", 1, :a]) == 1
      assert Xema.get(@data, ["tuple", 1, 1]) == {:b, 2}
    end

    test "returns nil for invalid path" do
      assert Xema.get(@data, ["users", 0, :foo]) == nil
      assert Xema.get(@data, [1, 0, :foo]) == nil
      assert Xema.get(@data, ["users", 10, :age]) == nil
      assert Xema.get(@data, ["account", 0, :age]) == nil
      assert Xema.get(@data, [:user, 0, :age]) == nil
      assert Xema.get(@data, ["users", :foo, :age]) == nil
    end

    test "raises an ArgumentError for invalid key" do
      assert_raise ArgumentError, fn -> Xema.get(@data, ["users", "0", :age]) == nil end
    end

    test "returns a list with Access.all/0 in path" do
      assert Xema.get(@data, ["users", Access.all(), :name]) == ["John", "Nick"]
    end
  end

  describe "fetch/2" do
    test "returns a value for a valid path" do
      assert Xema.fetch(@data, ["users", 0, :age]) == {:ok, 45}
      assert Xema.fetch(@data, ["users", -1, :age]) == {:ok, 21}
    end

    test "returns nil for invalid path" do
      assert {:error, %PathError{}} = Xema.fetch(@data, ["users", 0, :foo])
    end
  end

  describe "fetch!/2" do
    test "returns a value for a valid path" do
      assert Xema.fetch!(@data, ["users", 0, :age]) == 45
      assert Xema.fetch!(@data, ["users", -1, :age]) == 21
    end

    test "returns nil for invalid path" do
      message = ~s|path [\"users\", 0, :foo] not found in: #{inspect(@data)}|
      assert_raise PathError, message, fn -> Xema.fetch!(@data, ["users", 0, :foo]) end
    end
  end
end
