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
        source = {:any, foo: {:ref, "#/go"}, definitions: %{foo: :integer}}

      assert source |> Xema.new() |> Xema.source() == keywords
    end

    test "for items" do
      source = {:list, items: [:integer, :string]}

      assert source |> Xema.new() |> Xema.source() == source
    end
  end
end
