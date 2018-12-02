defmodule Draft4.AnyOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "anyOf" do
    setup do
      %{schema: Xema.new(any_of: [:integer, [minimum: 2]])}
    end

    test "first anyOf valid", %{schema: schema} do
      data = 1
      assert valid?(schema, data)
    end

    test "second anyOf valid", %{schema: schema} do
      data = 2.5
      assert valid?(schema, data)
    end

    test "both anyOf valid", %{schema: schema} do
      data = 3
      assert valid?(schema, data)
    end

    test "neither anyOf valid", %{schema: schema} do
      data = 1.5
      refute valid?(schema, data)
    end
  end

  describe "anyOf with base schema" do
    setup do
      %{
        schema:
          Xema.new({:string, [any_of: [[max_length: 2], [min_length: 4]]]})
      }
    end

    test "mismatch base schema", %{schema: schema} do
      data = 3
      refute valid?(schema, data)
    end

    test "one anyOf valid", %{schema: schema} do
      data = "foobar"
      assert valid?(schema, data)
    end

    test "both anyOf invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end

  describe "anyOf complex types" do
    setup do
      %{
        schema:
          Xema.new(
            any_of: [
              [properties: %{bar: :integer}, required: [:bar]],
              [properties: %{foo: :string}, required: [:foo]]
            ]
          )
      }
    end

    test "first anyOf valid (complex)", %{schema: schema} do
      data = %{bar: 2}
      assert valid?(schema, data)
    end

    test "second anyOf valid (complex)", %{schema: schema} do
      data = %{foo: "baz"}
      assert valid?(schema, data)
    end

    test "both anyOf valid (complex)", %{schema: schema} do
      data = %{bar: 2, foo: "baz"}
      assert valid?(schema, data)
    end

    test "neither anyOf valid (complex)", %{schema: schema} do
      data = %{bar: "quux", foo: 2}
      refute valid?(schema, data)
    end
  end
end
