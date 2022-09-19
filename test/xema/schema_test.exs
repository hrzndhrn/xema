defmodule Xema.SchemaTest do
  use ExUnit.Case

  doctest Xema.Schema

  alias Xema.Schema
  alias Xema.SchemaError

  describe "new/1" do
    test "raises an error for an invalid keyword" do
      assert_raise(KeyError, fn ->
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

      assert output = inspect(xema)

      if Version.match?(System.version(), "~> 1.14") do
        assert output ==
                 "%Xema{" <>
                   "schema: %Xema.Schema{items: [%Xema.Schema{type: :integer}], " <>
                   "type: :list}, refs: %{}}"
      else
        assert Regex.match?(~r/.*Xema.Schema.*/, output)
      end
    end

    test "any schema" do
      xema = Xema.new(items: [:integer])

      assert output = inspect(xema)

      if Version.match?(System.version(), "~> 1.14") do
        assert output ==
                 "%Xema{schema: %Xema.Schema{items: [%Xema.Schema{type: :integer}], " <>
                   "type: :any}, refs: %{}}"
      else
        assert Regex.match?(~r/.*Xema.Schema.*/, output)
      end
    end

    test "schema with ref" do
      xema = Xema.new({:map, properties: %{num: {:ref, "#"}}})

      assert output = inspect(xema)

      if Version.match?(System.version(), "~> 1.14") do
        assert output ==
                 """
                 %Xema{schema: %Xema.Schema{properties: \
                 %{num: %Xema.Schema{ref: %Xema.Ref{pointer: \"#\"}, \
                 type: :any}}, type: :map}, refs: %{}}\
                 """
      else
        assert Regex.match?(~r/.*Xema.Schema.*/, output)
      end
    end
  end

  test "keywords/0" do
    assert Schema.keywords() ==
             %Schema{} |> Map.keys() |> List.delete(:data) |> List.delete(:__struct__)
  end
end
