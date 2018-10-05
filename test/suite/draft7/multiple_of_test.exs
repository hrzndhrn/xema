defmodule Draft7.MultipleOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "by int" do
    setup do
      %{schema: Xema.new(:multiple_of, 2)}
    end

    test "int by int", %{schema: schema} do
      data = 10
      assert valid?(schema, data)
    end

    test "int by int fail", %{schema: schema} do
      data = 7
      refute valid?(schema, data)
    end

    test "ignores non-numbers", %{schema: schema} do
      data = "foo"
      assert valid?(schema, data)
    end
  end

  describe "by number" do
    setup do
      %{schema: Xema.new(:multiple_of, 1.5)}
    end

    test "zero is multiple of anything", %{schema: schema} do
      data = 0
      assert valid?(schema, data)
    end

    test "4.5 is multiple of 1.5", %{schema: schema} do
      data = 4.5
      assert valid?(schema, data)
    end

    test "35 is not multiple of 1.5", %{schema: schema} do
      data = 35
      refute valid?(schema, data)
    end
  end

  describe "by small number" do
    setup do
      %{schema: Xema.new(:multiple_of, 0.0001)}
    end

    test "0.0075 is multiple of 0.0001", %{schema: schema} do
      data = 0.0075
      assert valid?(schema, data)
    end

    test "0.00751 is not multiple of 0.0001", %{schema: schema} do
      data = 0.00751
      refute valid?(schema, data)
    end
  end
end
