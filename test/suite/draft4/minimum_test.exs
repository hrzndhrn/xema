defmodule Suite.Draft4.MinimumTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "minimum validation" do
    setup do
      %{schema: Xema.new(:minimum, 1.1)}
    end

    @tag :draft4
    @tag :minimum
    test "above the minimum is valid", %{schema: schema} do
      data = 2.6
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :minimum
    test "boundary point is valid", %{schema: schema} do
      data = 1.1
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :minimum
    test "below the minimum is invalid", %{schema: schema} do
      data = 0.6
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :minimum
    test "ignores non-numbers", %{schema: schema} do
      data = "x"
      assert is_valid?(schema, data)
    end
  end

  describe "exclusive_minimum validation" do
    setup do
      %{schema: Xema.new(:any, exclusive_minimum: true, minimum: 1.1)}
    end

    @tag :draft4
    @tag :minimum
    test "above the minimum is still valid", %{schema: schema} do
      data = 1.2
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :minimum
    test "boundary point is invalid", %{schema: schema} do
      data = 1.1
      refute is_valid?(schema, data)
    end
  end
end
