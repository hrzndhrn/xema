defmodule Draft4.MaximumTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "maximum validation" do
    setup do
      %{schema: Xema.new(:maximum, 3.0)}
    end

    test "below the maximum is valid", %{schema: schema} do
      data = 2.6
      assert valid?(schema, data)
    end

    test "boundary point is valid", %{schema: schema} do
      data = 3.0
      assert valid?(schema, data)
    end

    test "above the maximum is invalid", %{schema: schema} do
      data = 3.5
      refute valid?(schema, data)
    end

    test "ignores non-numbers", %{schema: schema} do
      data = "x"
      assert valid?(schema, data)
    end
  end

  describe "maximum validation (explicit false exclusivity)" do
    setup do
      %{schema: Xema.new(:any, exclusive_maximum: false, maximum: 3.0)}
    end

    test "below the maximum is valid", %{schema: schema} do
      data = 2.6
      assert valid?(schema, data)
    end

    test "boundary point is valid", %{schema: schema} do
      data = 3.0
      assert valid?(schema, data)
    end

    test "above the maximum is invalid", %{schema: schema} do
      data = 3.5
      refute valid?(schema, data)
    end

    test "ignores non-numbers", %{schema: schema} do
      data = "x"
      assert valid?(schema, data)
    end
  end

  describe "exclusiveMaximum validation" do
    setup do
      %{schema: Xema.new(:any, exclusive_maximum: true, maximum: 3.0)}
    end

    test "below the maximum is still valid", %{schema: schema} do
      data = 2.2
      assert valid?(schema, data)
    end

    test "boundary point is invalid", %{schema: schema} do
      data = 3.0
      refute valid?(schema, data)
    end
  end
end
