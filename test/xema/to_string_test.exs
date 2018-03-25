defmodule Xema.ToStringTest do
  use ExUnit.Case, async: true

  alias Xema

  describe "Xema.to_string" do
    test "with a simple any-schema" do
      schema = ~s(:any)
      xema = xema(schema)

      assert Xema.to_string(xema) == to_string(xema)
      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with a simple any-schema with an id and as :bar" do
      schema = ~s(:any, as: :bar, id: "foo")
      xema = xema(schema)

      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with an enum" do
      schema = ~s(:enum, [1, 2, 3])
      xema = xema(schema)

      # Shortcuts will expand to the equivalent schema.
      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with a integer-schema and keywords" do
      schema = ~s(:integer, maximum: 2, minimum: 1)
      xema = xema(schema)

      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with a list-schema and items as schemas" do
      schema = ~s(:list, items: [{:integer, minimum: 2}, :string])
      xema = xema(schema)

      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with a map-schema and properties (keys: atoms)" do
      schema = ~s(:map, properties: %{a: {:integer, minimum: 2}, b: :string})
      xema = xema(schema)

      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with a map-schema and properties (keys: strings)" do
      schema =
        ~s(:map, properties: %{"a" => {:integer, minimum: 2}, "b" => :string})

      xema = xema(schema)

      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with patter_properties" do
      schema = ~s(:pattern_properties, %{"^v" => :any})

      xema = xema(schema)

      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with a map schema and required properties" do
      schema =
        ~s(:map, properties: %{a: {:integer, minimum: 2}, b: :string}, required: [:x])

      xema = xema(schema)

      assert to_string(xema) == "Xema.new(#{schema})"
    end

    test "with a pattern" do
      assert_to_string(~s(:pattern, "^a*$"))
    end

    test "multiple types" do
      assert_to_string(~s([:integer, :string]))
    end

    test "format" do
      assert_to_string(~s(:format, :email))
    end

    test "definitions" do
      assert_to_string(~s(:definitions, %{foo: :integer}))
    end

    test "definitions and ref" do
      assert_to_string(~s(:any, definitions: %{foo: :integer}, ref: "#/go"))
    end

    test "definitions, properties, and ref" do
      assert_to_string("""
      :any,
      definitions: %{foo: :integer},
      properties: %{foo: {:ref, "#/definitions/foo"}}
      """)
    end
  end

  describe "Xema.to_string format :data" do
    test "with a simple any-schema and an id" do
      schema = ~s({:id, "foo"})
      xema = xema(schema)

      assert Xema.to_string(xema, format: :data) == schema
    end
  end

  defp assert_to_string(str) do
    str = trim(str)
    assert str |> trim() |> xema() |> Xema.to_string() == "Xema.new(#{str})"
  end

  defp xema(str) do
    case String.starts_with?(str, "{") do
      true -> Xema.new(Code.eval_string(str))
      false -> Xema.new(Code.eval_string("{#{str}}"))
    end
  end

  defp trim(str), do:
    str |> String.trim() |> String.replace(~r/\s+/, " ")
end
