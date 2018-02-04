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
      schema =
        ~s({:map, properties: %{"a" => {:integer, minimum: 2}, "b" => :string}})

      xema = xema(schema)

      assert Schema.to_string(xema.content) == schema
    end
  end

  describe "Xema.to_string" do
    test "with a simple any-schema" do
      schema = ~s(:any)
      xema = xema(schema)

      assert Xema.to_string(xema) == to_string(xema)
      assert to_string(xema) == "xema(#{schema})"
    end

    test "with a simple any-schema with an id and as :bar" do
      schema = ~s(:any, as: :bar, id: "foo")
      xema = xema(schema)

      assert to_string(xema) == "xema(#{schema})"
    end

    test "with an enum" do
      schema = ~s(:enum, [1, 2, 3])
      xema = xema(schema)

      # Shortcuts will expand to the equivalent schema.
      assert to_string(xema) == "xema(:any, enum: [1, 2, 3])"
    end

    test "with a integer-schema and keywords" do
      schema = ~s(:integer, maximum: 2, minimum: 1)
      xema = xema(schema)

      assert to_string(xema) == "xema(#{schema})"
    end

    test "with a list-schema and items as schemas" do
      schema = ~s(:list, items: [{:integer, minimum: 2}, :string])
      xema = xema(schema)

      assert to_string(xema) == "xema(#{schema})"
    end

    test "with a map-schema and properties (keys: atoms)" do
      schema = ~s(:map, properties: %{a: {:integer, minimum: 2}, b: :string})
      xema = xema(schema)

      assert to_string(xema) == "xema(#{schema})"
    end

    test "with a map-schema and properties (keys: strings)" do
      schema =
        ~s(:map, properties: %{"a" => {:integer, minimum: 2}, "b" => :string})

      xema = xema(schema)

      assert to_string(xema) == "xema(#{schema})"
    end
  end

  describe "Xema.to_string format :data" do
    test "with a simple any-schema and an id" do
      schema = ~s({:any, id: "foo"})
      xema = xema(schema)

      assert Xema.to_string(xema, format: :data) == schema
    end
  end

  defp xema(str) do
    case String.starts_with?(str, "{") do
      true -> Xema.new(Code.eval_string(str))
      false -> Xema.new(Code.eval_string("{#{str}}"))
    end
  end
end
