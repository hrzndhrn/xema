defmodule Draft6.ExclusiveMaximumTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "exclusiveMaximum validation" do
    setup do
      %{schema: Xema.new(:exclusive_maximum, 3.0)}
    end

    test "below the exclusiveMaximum is valid", %{schema: schema} do
      data = 2.2
      assert is_valid?(schema, data)
    end

    test "boundary point is invalid", %{schema: schema} do
      data = 3.0
      refute is_valid?(schema, data)
    end

    test "above the exclusiveMaximum is invalid", %{schema: schema} do
      data = 3.5
      refute is_valid?(schema, data)
    end

    test "ignores non-numbers", %{schema: schema} do
      data = "x"
      assert is_valid?(schema, data)
    end
  end
end
