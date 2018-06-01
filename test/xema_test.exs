defmodule XemaTest do
  use ExUnit.Case

  doctest Xema
  doctest Usage
  doctest UnsupportedFeatures

  describe "call xema/2 with tuple" do
    test "single-tuple equal simple schema-type" do
      assert Xema.new({:any}) == Xema.new(:any)
    end

    test "double-tuple equal regular xema call" do
      assert Xema.new({:any, maximum: 4}) == Xema.new(:any, maximum: 4)
    end

    test "call with two arguments raised ArgumentError" do
      assert_raise ArgumentError, "Invalid argument [maximum: 4].", fn ->
        Xema.new({:any}, maximum: 4)
      end
    end
  end
end
