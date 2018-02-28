defmodule Suite.Draft4.DependenciesTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "dependencies" do
    setup do
      %{schema: Xema.new(:dependencies, %{bar: ["foo"]})}
    end

    @tag :draft4
    @tag :dependencies
    test "neither", %{schema: schema} do
      data = %{}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "nondependant", %{schema: schema} do
      data = %{foo: 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "with dependency", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "missing dependency", %{schema: schema} do
      data = %{bar: 2}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "ignores arrays", %{schema: schema} do
      data = ["bar"]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "ignores strings", %{schema: schema} do
      data = "foobar"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert is_valid?(schema, data)
    end
  end

  describe "multiple dependencies" do
    setup do
      %{schema: Xema.new(:dependencies, %{quux: ["foo", "bar"]})}
    end

    @tag :draft4
    @tag :dependencies
    test "neither", %{schema: schema} do
      data = %{}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "nondependants", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "with dependencies", %{schema: schema} do
      data = %{bar: 2, foo: 1, quux: 3}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "missing dependency", %{schema: schema} do
      data = %{foo: 1, quux: 2}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "missing other dependency", %{schema: schema} do
      data = %{bar: 1, quux: 2}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "missing both dependencies", %{schema: schema} do
      data = %{quux: 1}
      refute is_valid?(schema, data)
    end
  end

  describe "multiple dependencies subschema" do
    setup do
      %{
        schema:
          Xema.new(:dependencies, %{
            bar: {:properties, %{bar: :integer, foo: :integer}}
          })
      }
    end

    @tag :draft4
    @tag :dependencies
    test "valid", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "no dependency", %{schema: schema} do
      data = %{foo: "quux"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "wrong type", %{schema: schema} do
      data = %{bar: 2, foo: "quux"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "wrong type other", %{schema: schema} do
      data = %{bar: "quux", foo: 2}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :dependencies
    test "wrong type both", %{schema: schema} do
      data = %{bar: "quux", foo: "quux"}
      refute is_valid?(schema, data)
    end
  end
end
