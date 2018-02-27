defmodule Suite.Draft4.MaximumTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "maximum validation" do
    setup do
      %{schema: Xema.new(:maximum, 3.0)}
    end

    @tag :draft4
    @tag :maximum
    test "below the maximum is valid", %{schema: schema} do
      data = 2.6
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :maximum
    test "boundary point is valid", %{schema: schema} do
      data = 3.0
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :maximum
    test "above the maximum is invalid", %{schema: schema} do
      data = 3.5
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :maximum
    test "ignores non-numbers", %{schema: schema} do
      data = "x"
      assert is_valid?(schema, data)
    end
  end

  describe "exclusive_maximum validation" do
    setup do
      %{schema: Xema.new(:any, exclusive_maximum: true, maximum: 3.0)}
    end

    @tag :draft4
    @tag :maximum
    test "below the maximum is still valid", %{schema: schema} do
      data = 2.2
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :maximum
    test "boundary point is invalid", %{schema: schema} do
      data = 3.0
      refute is_valid?(schema, data)
    end
  end
end
