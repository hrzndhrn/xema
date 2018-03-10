defmodule Draft4.AdditionalItemsTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "additionalItems as schema" do
    setup do
      %{schema: Xema.new(:any, additional_items: :integer, items: [:any])}
    end

    @tag :draft4
    @tag :additional_items
    test "additional items match schema", %{schema: schema} do
      data = [nil, 2, 3, 4]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :additional_items
    test "additional items do not match schema", %{schema: schema} do
      data = [nil, 2, 3, "foo"]
      refute is_valid?(schema, data)
    end
  end

  describe "items is schema, no additionalItems" do
    setup do
      %{schema: Xema.new(:any, additional_items: false, items: :any)}
    end

    @tag :draft4
    @tag :additional_items
    test "all items match schema", %{schema: schema} do
      data = [1, 2, 3, 4, 5]
      assert is_valid?(schema, data)
    end
  end

  describe "array of items with no additionalItems" do
    setup do
      %{
        schema:
          Xema.new(:any, additional_items: false, items: [:any, :any, :any])
      }
    end

    @tag :draft4
    @tag :additional_items
    test "fewer number of items present", %{schema: schema} do
      data = [1, 2]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :additional_items
    test "equal number of items present", %{schema: schema} do
      data = [1, 2, 3]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :additional_items
    test "additional items are not permitted", %{schema: schema} do
      data = [1, 2, 3, 4]
      refute is_valid?(schema, data)
    end
  end

  describe "additionalItems as false without items" do
    setup do
      %{schema: Xema.new(:additional_items, false)}
    end

    @tag :draft4
    @tag :additional_items
    test "items defaults to empty schema so everything is valid", %{
      schema: schema
    } do
      data = [1, 2, 3, 4, 5]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :additional_items
    test "ignores non-arrays", %{schema: schema} do
      data = %{foo: "bar"}
      assert is_valid?(schema, data)
    end
  end

  describe "additionalItems are allowed by default" do
    setup do
      %{schema: Xema.new(:items, [:integer])}
    end

    @tag :draft4
    @tag :additional_items
    test "only the first item is validated", %{schema: schema} do
      data = [1, "foo", false]
      assert is_valid?(schema, data)
    end
  end
end
