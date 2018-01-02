defmodule XemaTest do
  use ExUnit.Case

  doctest Xema
  doctest Readme

  import Xema

  describe "call xema/2 with tuple" do
    test "single-tuple equal simple schema-type" do
      assert xema({:any}) == xema(:any)
    end

    test "double-tuple equal regular xema call" do
      assert xema({:any, maximum: 4}) == xema(:any, maximum: 4)
    end

    test "call with two arguments raised ArgumentError" do
      assert_raise ArgumentError, "Invalid argument [maximum: 4]", fn ->
        xema({:any}, maximum: 4)
      end
    end
  end
end
