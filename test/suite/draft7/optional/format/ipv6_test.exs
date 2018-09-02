defmodule Draft7.Optional.Format.Ipv6Test do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "validation of IPv6 addresses" do
    setup do
      %{schema: Xema.new(:format, :ipv6)}
    end

    test "a valid IPv6 address", %{schema: schema} do
      data = "::1"
      assert is_valid?(schema, data)
    end

    test "an IPv6 address with out-of-range values", %{schema: schema} do
      data = "12345::"
      refute is_valid?(schema, data)
    end

    test "an IPv6 address with too many components", %{schema: schema} do
      data = "1:1:1:1:1:1:1:1:1:1:1:1:1:1:1:1"
      refute is_valid?(schema, data)
    end

    test "an IPv6 address containing illegal characters", %{schema: schema} do
      data = "::laptop"
      refute is_valid?(schema, data)
    end
  end
end
