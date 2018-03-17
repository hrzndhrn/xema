defmodule Draft4.MinimumTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "minimum validation" do
    setup do
      %{schema: Xema.new(:minimum, 1.1)}
    end

    test "above the minimum is valid", %{schema: schema} do
      data = 2.6
      assert is_valid?(schema, data)
    end

    test "boundary point is valid", %{schema: schema} do
      data = 1.1
      assert is_valid?(schema, data)
    end

    test "below the minimum is invalid", %{schema: schema} do
      data = 0.6
      refute is_valid?(schema, data)
    end

    test "ignores non-numbers", %{schema: schema} do
      data = "x"
      assert is_valid?(schema, data)
    end
  end

  describe "exclusiveMinimum validation" do
    setup do
      %{schema: Xema.new(:any, exclusive_minimum: true, minimum: 1.1)}
    end

    test "above the minimum is still valid", %{schema: schema} do
      data = 1.2
      assert is_valid?(schema, data)
    end

    test "boundary point is invalid", %{schema: schema} do
      data = 1.1
      refute is_valid?(schema, data)
    end
  end
end
