defmodule Suite.Draft4.AllOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "all_of" do
    setup do
      %{
        schema:
          Xema.new(:all_of, [
            {:any, properties: %{"bar" => :integer}, required: ["bar"]},
            {:any, properties: %{"foo" => :string}, required: ["foo"]}
          ])
      }
    end

    @tag :draft4
    @tag :all_of
    test "allOf", %{schema: schema} do
      data = %{"bar" => 2, "foo" => "baz"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "mismatch second", %{schema: schema} do
      data = %{"foo" => "baz"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "mismatch first", %{schema: schema} do
      data = %{"bar" => 2}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "wrong type", %{schema: schema} do
      data = %{"bar" => "quux", "foo" => "baz"}
      refute is_valid?(schema, data)
    end
  end

  describe "all_of with base schema" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            all_of: [
              {:any, properties: %{"foo" => :string}, required: ["foo"]},
              {:any, properties: %{"baz" => nil}, required: ["baz"]}
            ],
            properties: %{"bar" => :integer},
            required: ["bar"]
          )
      }
    end

    @tag :draft4
    @tag :all_of
    test "valid", %{schema: schema} do
      data = %{"bar" => 2, "baz" => nil, "foo" => "quux"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "mismatch base schema", %{schema: schema} do
      data = %{"baz" => nil, "foo" => "quux"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "mismatch first allOf", %{schema: schema} do
      data = %{"bar" => 2, "baz" => nil}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "mismatch second allOf", %{schema: schema} do
      data = %{"bar" => 2, "foo" => "quux"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "mismatch both", %{schema: schema} do
      data = %{"bar" => 2}
      refute is_valid?(schema, data)
    end
  end

  describe "all_of simple types" do
    setup do
      %{schema: Xema.new(:all_of, [{:maximum, 30}, {:minimum, 20}])}
    end

    @tag :draft4
    @tag :all_of
    test "valid", %{schema: schema} do
      data = 25
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :all_of
    test "mismatch one", %{schema: schema} do
      data = 35
      refute is_valid?(schema, data)
    end
  end
end
