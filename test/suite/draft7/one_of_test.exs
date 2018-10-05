defmodule Draft7.OneOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "oneOf" do
    setup do
      %{schema: Xema.new(:one_of, [:integer, {:minimum, 2}])}
    end

    test "first oneOf valid", %{schema: schema} do
      data = 1
      assert valid?(schema, data)
    end

    test "second oneOf valid", %{schema: schema} do
      data = 2.5
      assert valid?(schema, data)
    end

    test "both oneOf valid", %{schema: schema} do
      data = 3
      refute valid?(schema, data)
    end

    test "neither oneOf valid", %{schema: schema} do
      data = 1.5
      refute valid?(schema, data)
    end
  end

  describe "oneOf with base schema" do
    setup do
      %{schema: Xema.new(:string, one_of: [min_length: 2, max_length: 4])}
    end

    test "mismatch base schema", %{schema: schema} do
      data = 3
      refute valid?(schema, data)
    end

    test "one oneOf valid", %{schema: schema} do
      data = "foobar"
      assert valid?(schema, data)
    end

    test "both oneOf valid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end

  describe "oneOf with boolean schemas, all true" do
    setup do
      %{schema: Xema.new(:one_of, [true, true, true])}
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end

  describe "oneOf with boolean schemas, one true" do
    setup do
      %{schema: Xema.new(:one_of, [true, false, false])}
    end

    test "any value is valid", %{schema: schema} do
      data = "foo"
      assert valid?(schema, data)
    end
  end

  describe "oneOf with boolean schemas, more than one true" do
    setup do
      %{schema: Xema.new(:one_of, [true, true, false])}
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end

  describe "oneOf with boolean schemas, all false" do
    setup do
      %{schema: Xema.new(:one_of, [false, false, false])}
    end

    test "any value is invalid", %{schema: schema} do
      data = "foo"
      refute valid?(schema, data)
    end
  end

  describe "oneOf complex types" do
    setup do
      %{
        schema:
          Xema.new(:one_of,
            any: [properties: %{bar: :integer}, required: ["bar"]],
            any: [properties: %{foo: :string}, required: ["foo"]]
          )
      }
    end

    test "first oneOf valid (complex)", %{schema: schema} do
      data = %{bar: 2}
      assert valid?(schema, data)
    end

    test "second oneOf valid (complex)", %{schema: schema} do
      data = %{foo: "baz"}
      assert valid?(schema, data)
    end

    test "both oneOf valid (complex)", %{schema: schema} do
      data = %{bar: 2, foo: "baz"}
      refute valid?(schema, data)
    end

    test "neither oneOf valid (complex)", %{schema: schema} do
      data = %{bar: "quux", foo: 2}
      refute valid?(schema, data)
    end
  end
end
