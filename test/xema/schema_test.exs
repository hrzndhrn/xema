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

  describe "inspect/1" do
    test "list schema" do
      xema = Xema.new({:list, items: [:integer]})

      assert inspect(xema) ==
               "%Xema{refs: %{}, schema: " <>
                 "%Xema.Schema{items: " <>
                 "[%Xema.Schema{type: :integer}], " <>
                 "type: :list}}"
    end

    test "any schema" do
      xema = Xema.new(items: [:integer])

      assert inspect(xema) ==
               "%Xema{refs: %{}, schema: " <>
                 "%Xema.Schema{items: " <>
                 "[%Xema.Schema{type: :integer}]}}"
    end

    test "schema with ref" do
      xema = Xema.new({:map, properties: %{num: {:ref, "#/num"}}})

      assert inspect(xema) ==
               "%Xema{refs: %{}, schema: " <>
                 "%Xema.Schema{properties: " <>
                 "%{num: %Xema.Schema{ref: " <>
                 "%Xema.Ref{pointer: \"#/num\"}}}, " <>
                 "type: :map}}"
    end
  end

  test "keywords/0" do
    assert Schema.keywords() == %Schema{} |> Map.keys() |> List.delete(:data)
  end
end
