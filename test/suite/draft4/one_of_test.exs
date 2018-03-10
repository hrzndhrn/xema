defmodule Draft4.OneOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "oneOf" do
    setup do
      %{schema: Xema.new(:one_of, [:integer, {:minimum, 2}])}
    end

    @tag :draft4
    @tag :one_of
    test "first oneOf valid", %{schema: schema} do
      data = 1
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "second oneOf valid", %{schema: schema} do
      data = 2.5
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "both oneOf valid", %{schema: schema} do
      data = 3
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "neither oneOf valid", %{schema: schema} do
      data = 1.5
      refute is_valid?(schema, data)
    end
  end

  describe "oneOf with base schema" do
    setup do
      %{schema: Xema.new(:string, one_of: [{:min_length, 2}, {:max_length, 4}])}
    end

    @tag :draft4
    @tag :one_of
    test "mismatch base schema", %{schema: schema} do
      data = 3
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "one oneOf valid", %{schema: schema} do
      data = "foobar"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "both oneOf valid", %{schema: schema} do
      data = "foo"
      refute is_valid?(schema, data)
    end
  end

  describe "oneOf complex types" do
    setup do
      %{
        schema:
          Xema.new(:one_of, [
            {:any, properties: %{bar: :integer}, required: ["bar"]},
            {:any, properties: %{foo: :string}, required: ["foo"]}
          ])
      }
    end

    @tag :draft4
    @tag :one_of
    test "first oneOf valid (complex)", %{schema: schema} do
      data = %{bar: 2}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "second oneOf valid (complex)", %{schema: schema} do
      data = %{foo: "baz"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "both oneOf valid (complex)", %{schema: schema} do
      data = %{bar: 2, foo: "baz"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :one_of
    test "neither oneOf valid (complex)", %{schema: schema} do
      data = %{bar: "quux", foo: 2}
      refute is_valid?(schema, data)
    end
  end
end
