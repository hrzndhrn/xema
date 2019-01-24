defmodule Xema.SourceTest do
  use ExUnit.Case, async: true

  alias Xema

  describe "Xema.source/0 returns the source" do
    test "for a simple any type schema" do
      source = :any

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "for an any type schema with keywords" do
      {_, keywords} = source = {:any, maximum: 2, minimum: 5}

      assert source |> Xema.new() |> Xema.source() == keywords
    end

    test "for an integer type schema with keywords" do
      source = {:integer, maximum: 2, minimum: 5}

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "of a schema with simple nested schema" do
      source = {
        :map,
        properties: %{
          num: :integer
        }
      }

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "of a schema with additional data" do
      source = {
        :map,
        bar: 17,
        foo: 42,
        properties: %{
          foo: :integer
        }
      }

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "of a schema with nested schema" do
      source = {
        :map,
        properties: %{
          num: {:integer, minimum: 2}
        }
      }

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "of a schema with nested any type schema" do
      source = {
        :map,
        properties: %{
          num: [minimum: 2]
        }
      }

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "of a schema with ref" do
      source = {
        :map,
        properties: %{
          num: [minimum: 2],
          foo: {:ref, "#"}
        }
      }

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "for dependencies with boolean subschemas and atom keys" do
      source = [dependencies: %{bar: true, foo: false}]

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "dependencies with boolean subschemas and string keys" do
      source = [dependencies: %{"bar" => true, "foo" => false}]

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "for definitions and ref" do
      {_, keywords} =
        source =
        {:any, bar: {:ref, "#/definitions/foo"}, definitions: %{foo: :integer}}

      assert source |> Xema.new() |> Xema.source() == keywords
    end

    test "for definitions and ref without sibling" do
      keywords = [
        definitions: %{
          reffed: :list
        },
        properties: %{
          foo: [ref: "#/definitions/reffed"]
        }
      ]

      expected = [
        definitions: %{
          reffed: :list
        },
        properties: %{
          foo: {:ref, "#/definitions/reffed"}
        }
      ]

      assert keywords |> Xema.new() |> Xema.source() == expected
    end

    test "for definitions and ref as tuple" do
      keywords = [
        definitions: %{
          reffed: :list
        },
        properties: %{
          foo: {:ref, "#/definitions/reffed"}
        }
      ]

      assert keywords |> Xema.new() |> Xema.source() == keywords
    end

    test "for definitions and ref with sibling" do
      keywords = [
        definitions: %{
          reffed: :list
        },
        properties: %{
          foo: [
            ref: "#/definitions/reffed",
            max_items: 2
          ]
        }
      ]

      assert keywords |> Xema.new() |> Xema.source() == keywords
    end

    test "for items" do
      source = {:list, items: [:integer, :string]}

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "for properties with required fields" do
      source = {:map, properties: %{num: :number}, required: [:num]}

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "for regex patterin" do
      source = [pattern: ~r/foo/]

      assert source |> Xema.new() |> Xema.source() == source
    end

    test "for pattern_properties" do
      source =
        {:map,
         pattern_properties: %{"n.*": [minimum: 0]},
         properties: %{
           num: :number,
           str: :string
         }}

      expected =
        {:map,
         pattern_properties: %{~r/n.*/ => [minimum: 0]},
         properties: %{
           num: :number,
           str: :string
         }}

      assert source |> Xema.new() |> Xema.source() == expected
    end
  end
end
