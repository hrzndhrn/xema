defmodule Suite.Draft4.NotTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "not" do
    setup do
      %{schema: Xema.new(:not, :integer)}
    end

    @tag :draft4
    @tag :not
    test "allowed", %{schema: schema} do
      data = "foo"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :not
    test "disallowed", %{schema: schema} do
      data = 1
      refute is_valid?(schema, data)
    end
  end

  describe "not multiple types" do
    setup do
      %{schema: Xema.new(:not, nil)}
    end

    @tag :draft4
    @tag :not
    test "valid", %{schema: schema} do
      data = "foo"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :not
    test "mismatch", %{schema: schema} do
      data = 1
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :not
    test "other mismatch", %{schema: schema} do
      data = true
      refute is_valid?(schema, data)
    end
  end

  describe "not more complex schema" do
    setup do
      %{schema: Xema.new(:not, {:map, properties: %{foo: :string}})}
    end

    @tag :draft4
    @tag :not
    test "match", %{schema: schema} do
      data = 1
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :not
    test "other match", %{schema: schema} do
      data = %{foo: 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :not
    test "mismatch", %{schema: schema} do
      data = %{foo: "bar"}
      refute is_valid?(schema, data)
    end
  end

  describe "forbidden property" do
    setup do
      %{schema: Xema.new(:properties, %{foo: {:not, :any}})}
    end

    @tag :draft4
    @tag :not
    test "property present", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :not
    test "property absent", %{schema: schema} do
      data = %{bar: 1, baz: 2}
      assert is_valid?(schema, data)
    end
  end
end
