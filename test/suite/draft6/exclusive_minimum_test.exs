defmodule Draft6.ExclusiveMinimumTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "exclusiveMinimum validation" do
    setup do
      %{schema: Xema.new(exclusive_minimum: 1.1)}
    end

    test "above the exclusiveMinimum is valid", %{schema: schema} do
      data = 1.2
      assert valid?(schema, data)
    end

    test "boundary point is invalid", %{schema: schema} do
      data = 1.1
      refute valid?(schema, data)
    end

    test "below the exclusiveMinimum is invalid", %{schema: schema} do
      data = 0.6
      refute valid?(schema, data)
    end

    test "ignores non-numbers", %{schema: schema} do
      data = "x"
      assert valid?(schema, data)
    end
  end
end
