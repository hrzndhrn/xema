defmodule Suite.Draft4.MaxPropertiesTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "max_properties validation" do
    setup do
      %{schema: Xema.new(:max_properties, 2)}
    end

    @tag :draft4
    @tag :max_properties
    test "shorter is valid", %{schema: schema} do
      data = %{"foo" => 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_properties
    test "exact length is valid", %{schema: schema} do
      data = %{"bar" => 2, "foo" => 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_properties
    test "too long is invalid", %{schema: schema} do
      data = %{"bar" => 2, "baz" => 3, "foo" => 1}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_properties
    test "ignores arrays", %{schema: schema} do
      data = [1, 2, 3]
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_properties
    test "ignores strings", %{schema: schema} do
      data = "foobar"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_properties
    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert is_valid?(schema, data)
    end
  end
end
