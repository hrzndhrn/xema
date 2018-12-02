defmodule Draft6.AllOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "allOf" do
    setup do
      %{
        schema:
          Xema.new(
            all_of: [
              [properties: %{bar: :integer}, required: [:bar]],
              [properties: %{foo: :string}, required: [:foo]]
            ]
          )
      }
    end

    test "allOf", %{schema: schema} do
      data = %{bar: 2, foo: "baz"}
      assert valid?(schema, data)
    end

    test "mismatch second", %{schema: schema} do
      data = %{foo: "baz"}
      refute valid?(schema, data)
    end

    test "mismatch first", %{schema: schema} do
      data = %{bar: 2}
      refute valid?(schema, data)
    end

    test "wrong type", %{schema: schema} do
      data = %{bar: "quux", foo: "baz"}
      refute valid?(schema, data)
    end
  end

  describe "allOf with base schema" do
    setup do
      %{
        schema:
          Xema.new(
            all_of: [
              [properties: %{foo: :string}, required: [:foo]],
              [properties: %{baz: nil}, required: [:baz]]
            ],
            properties: %{bar: :integer},
            required: [:bar]
          )
      }
    end

    test "valid", %{schema: schema} do
      data = %{bar: 2, baz: nil, foo: "quux"}
      assert valid?(schema, data)
    end

    test "mismatch base schema", %{schema: schema} do
      data = %{baz: nil, foo: "quux"}
      refute valid?(schema, data)
    end

    test "mismatch first allOf", %{schema: schema} do
      data = %{bar: 2, baz: nil}
      refute valid?(schema, data)
    end

    test "mismatch second allOf", %{schema: schema} do
      data = %{bar: 2, foo: "quux"}
      refute valid?(schema, data)
    end

    test "mismatch both", %{schema: schema} do
      data = %{bar: 2}
      refute valid?(schema, data)
    end
  end

  describe "allOf simple types" do
    setup do
      %{schema: Xema.new(all_of: [[maximum: 30], [minimum: 20]])}
    end

    test "valid", %{schema: schema} do
      data = 25
      assert valid?(schema, data)
    end

    test "mismatch one", %{schema: schema} do
      data = 35
      refute valid?(schema, data)
    end
  end

  describe "allOf with boolean schemas, all true" do
    setup do
      %{schema: Xema.new(all_of: [true, true])}
    end

    test "any value is valid", %{schema: schema} do
      data = "foo"
      assert valid?(schema, data)
    end
  end

  describe "allOf with boolean schemas, some false" do
    setup do
      %{schema: Xema.new(all_of: [true, false])}
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end

  describe "allOf with boolean schemas, all false" do
    setup do
      %{schema: Xema.new(all_of: [false, false])}
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end
end
