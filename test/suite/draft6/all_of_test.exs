defmodule Draft6.AllOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "allOf" do
    setup do
      %{
        schema:
          Xema.new(
            :all_of,
            any: [properties: %{bar: :integer}, required: ["bar"]],
            any: [properties: %{foo: :string}, required: ["foo"]]
          )
      }
    end

    test "allOf", %{schema: schema} do
      data = %{bar: 2, foo: "baz"}
      assert is_valid?(schema, data)
    end

    test "mismatch second", %{schema: schema} do
      data = %{foo: "baz"}
      refute is_valid?(schema, data)
    end

    test "mismatch first", %{schema: schema} do
      data = %{bar: 2}
      refute is_valid?(schema, data)
    end

    test "wrong type", %{schema: schema} do
      data = %{bar: "quux", foo: "baz"}
      refute is_valid?(schema, data)
    end
  end

  describe "allOf with base schema" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            all_of: [
              any: [properties: %{foo: :string}, required: ["foo"]],
              any: [properties: %{baz: nil}, required: ["baz"]]
            ],
            properties: %{bar: :integer},
            required: ["bar"]
          )
      }
    end

    test "valid", %{schema: schema} do
      data = %{bar: 2, baz: nil, foo: "quux"}
      assert is_valid?(schema, data)
    end

    test "mismatch base schema", %{schema: schema} do
      data = %{baz: nil, foo: "quux"}
      refute is_valid?(schema, data)
    end

    test "mismatch first allOf", %{schema: schema} do
      data = %{bar: 2, baz: nil}
      refute is_valid?(schema, data)
    end

    test "mismatch second allOf", %{schema: schema} do
      data = %{bar: 2, foo: "quux"}
      refute is_valid?(schema, data)
    end

    test "mismatch both", %{schema: schema} do
      data = %{bar: 2}
      refute is_valid?(schema, data)
    end
  end

  describe "allOf simple types" do
    setup do
      %{schema: Xema.new(:all_of, maximum: 30, minimum: 20)}
    end

    test "valid", %{schema: schema} do
      data = 25
      assert is_valid?(schema, data)
    end

    test "mismatch one", %{schema: schema} do
      data = 35
      refute is_valid?(schema, data)
    end
  end

  describe "allOf with boolean schemas, all true" do
    setup do
      %{schema: Xema.new(:all_of, [true, true])}
    end

    test "any value is valid", %{schema: schema} do
      data = "foo"
      assert is_valid?(schema, data)
    end
  end

  describe "allOf with boolean schemas, some false" do
    setup do
      %{schema: Xema.new(:all_of, [true, false])}
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute is_valid?(schema, data)
    end
  end

  describe "allOf with boolean schemas, all false" do
    setup do
      %{schema: Xema.new(:all_of, [false, false])}
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute is_valid?(schema, data)
    end
  end
end
