defmodule Draft7.Optional.Format.Ipv4Test do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "validation of IP addresses" do
    setup do
      %{schema: Xema.new(:format, :ipv4)}
    end

    test "a valid IP address", %{schema: schema} do
      data = "192.168.0.1"
      assert is_valid?(schema, data)
    end

    test "an IP address with too many components", %{schema: schema} do
      data = "127.0.0.0.1"
      refute is_valid?(schema, data)
    end

    test "an IP address with out-of-range values", %{schema: schema} do
      data = "256.256.256.256"
      refute is_valid?(schema, data)
    end

    test "an IP address without 4 components", %{schema: schema} do
      data = "127.0"
      refute is_valid?(schema, data)
    end

    test "an IP address as an integer", %{schema: schema} do
      data = "0x7f000001"
      refute is_valid?(schema, data)
    end
  end
end
