defmodule Xema.SchemaTest do
  use ExUnit.Case

  doctest Xema.Schema

  alias Xema.Schema
  alias Xema.SchemaError

  describe "new/1" do
    test "raises an error for an invalid keyword" do
      message = "key :foo not found in: %Xema.Schema{}"

      assert_raise(KeyError, message, fn ->
        Schema.new(type: :any, foo: :foo)
      end)
    end

    test "raises an error if type is missing" do
      assert_raise(SchemaError, "Missing type.", fn ->
        Schema.new([])
      end)
    end

    test "raises an error for an invalid type" do
      assert_raise(SchemaError, "Invalid type :foo.", fn ->
        Schema.new(type: :foo)
      end)
    end

    test "raises an error for invalid types" do
      assert_raise(SchemaError, "Invalid types [:foo, :bar].", fn ->
        Schema.new(type: [:foo, :string, :bar])
      end)
    end
  end
end
