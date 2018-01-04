defmodule Xema.ToStringTest do
  use ExUnit.Case, async: true

  alias Xema
  alias Xema.Schema

  describe "Xema.Schema.to_string" do
    test "with a simple any-schema" do
      schema = "{:any}"
      xema = xema(schema)

      assert Schema.to_string(xema.content) == schema
    end

    test "with a integer-schema and keywords" do
      schema = "{:integer, maximum: 2, minimum: 1}"
      xema = xema(schema)

      assert Schema.to_string(xema.content) == schema
    end

    test "with a list-schema and items as schemas" do
      schema = "{:list, items: [{:integer, minimum: 2}, :string]}"
      xema = xema(schema)

      assert Schema.to_string(xema.content) == schema
    end

    test "with a map-schema and properties (keys: atoms)" do
      schema = "{:map, properties: %{a: {:integer, minimum: 2}, b: :string}}"
      xema = xema(schema)

      assert Schema.to_string(xema.content) == schema
    end

    test "with a map-schema and properties (keys: strings)" do
      schema = ~s({:map, properties: %{"a" => {:integer, minimum: 2}, "b" => :string}})
      xema = xema(schema)

      assert Schema.to_string(xema.content) == schema
    end
  end

  describe "Xema.to_string" do
    test "with a simple any-schema and an id" do
      schema = ~s({:any, id: "foo"})
      xema = xema(schema)

      assert Xema.to_string(xema) == schema
    end
  end

  defp xema(str), do: Xema.xema(Code.eval_string(str))
end
