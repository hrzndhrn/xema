defmodule JsonSchemaTestSuite.Draft7.Optional.Format.Ipv4 do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of IP addresses" do
    setup do
      %{schema: Xema.from_json_schema(%{"format" => "ipv4"})}
    end

    test "a valid IP address", %{schema: schema} do
      assert valid?(schema, "192.168.0.1")
    end

    test "an IP address with too many components", %{schema: schema} do
      refute valid?(schema, "127.0.0.0.1")
    end

    test "an IP address with out-of-range values", %{schema: schema} do
      refute valid?(schema, "256.256.256.256")
    end

    test "an IP address without 4 components", %{schema: schema} do
      refute valid?(schema, "127.0")
    end

    test "an IP address as an integer", %{schema: schema} do
      refute valid?(schema, "0x7f000001")
    end
  end
end
