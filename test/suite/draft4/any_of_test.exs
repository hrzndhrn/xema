defmodule Suite.Draft4.AnyOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "any_of" do
    setup do
      %{schema: Xema.new(:any_of, [:integer, {:minimum, 2}])}
    end

    @tag :draft4
    @tag :any_of
    test "first anyOf valid", %{schema: schema} do
      data = 1
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "second anyOf valid", %{schema: schema} do
      data = 2.5
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "both anyOf valid", %{schema: schema} do
      data = 3
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "neither anyOf valid", %{schema: schema} do
      data = 1.5
      refute is_valid?(schema, data)
    end
  end

  describe "any_of with base schema" do
    setup do
      %{schema: Xema.new(:string, any_of: [{:max_length, 2}, {:min_length, 4}])}
    end

    @tag :draft4
    @tag :any_of
    test "mismatch base schema", %{schema: schema} do
      data = 3
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "one anyOf valid", %{schema: schema} do
      data = "foobar"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "both anyOf invalid", %{schema: schema} do
      data = "foo"
      refute is_valid?(schema, data)
    end
  end

  describe "any_of complex types" do
    setup do
      %{
        schema:
          Xema.new(:any_of, [
            {:any, properties: %{bar: :integer}, required: ["bar"]},
            {:any, properties: %{foo: :string}, required: ["foo"]}
          ])
      }
    end

    @tag :draft4
    @tag :any_of
    test "first anyOf valid (complex)", %{schema: schema} do
      data = %{bar: 2}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "second anyOf valid (complex)", %{schema: schema} do
      data = %{foo: "baz"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "both anyOf valid (complex)", %{schema: schema} do
      data = %{bar: 2, foo: "baz"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :any_of
    test "neither anyOf valid (complex)", %{schema: schema} do
      data = %{bar: "quux", foo: 2}
      refute is_valid?(schema, data)
    end
  end
end
