defmodule JsonSchemaTestSuite.Draft7.Optional.Format.Ipv6Test do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of IPv6 addresses| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "ipv6"},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|a valid IPv6 address|, %{schema: schema} do
      assert valid?(schema, "::1")
    end

    test ~s|an IPv6 address with out-of-range values|, %{schema: schema} do
      refute valid?(schema, "12345::")
    end

    test ~s|an IPv6 address with too many components|, %{schema: schema} do
      refute valid?(schema, "1:1:1:1:1:1:1:1:1:1:1:1:1:1:1:1")
    end

    test ~s|an IPv6 address containing illegal characters|, %{schema: schema} do
      refute valid?(schema, "::laptop")
    end

    test ~s|no digits is valid|, %{schema: schema} do
      assert valid?(schema, "::")
    end

    test ~s|leading colons is valid|, %{schema: schema} do
      assert valid?(schema, "::42:ff:1")
    end

    test ~s|trailing colons is valid|, %{schema: schema} do
      assert valid?(schema, "d6::")
    end

    test ~s|missing leading octet is invalid|, %{schema: schema} do
      refute valid?(schema, ":2:3:4:5:6:7:8")
    end

    test ~s|missing trailing octet is invalid|, %{schema: schema} do
      refute valid?(schema, "1:2:3:4:5:6:7:")
    end

    test ~s|missing leading octet with omitted octets later|, %{schema: schema} do
      refute valid?(schema, ":2:3:4::8")
    end

    test ~s|two sets of double colons is invalid|, %{schema: schema} do
      refute valid?(schema, "1::d6::42")
    end

    test ~s|mixed format with the ipv4 section as decimal octets|, %{schema: schema} do
      assert valid?(schema, "1::d6:192.168.0.1")
    end

    test ~s|mixed format with double colons between the sections|, %{schema: schema} do
      assert valid?(schema, "1:2::192.168.0.1")
    end

    test ~s|mixed format with ipv4 section with octet out of range|, %{schema: schema} do
      refute valid?(schema, "1::2:192.168.256.1")
    end

    test ~s|mixed format with ipv4 section with a hex octet|, %{schema: schema} do
      refute valid?(schema, "1::2:192.168.ff.1")
    end

    test ~s|mixed format with leading double colons (ipv4-mapped ipv6 address)|, %{schema: schema} do
      assert valid?(schema, "::ffff:192.168.0.1")
    end

    test ~s|triple colons is invalid|, %{schema: schema} do
      refute valid?(schema, "1:2:3:4:5:::8")
    end

    test ~s|8 octets|, %{schema: schema} do
      assert valid?(schema, "1:2:3:4:5:6:7:8")
    end

    test ~s|insufficient octets without double colons|, %{schema: schema} do
      refute valid?(schema, "1:2:3:4:5:6:7")
    end

    test ~s|no colons is invalid|, %{schema: schema} do
      refute valid?(schema, "1")
    end

    test ~s|ipv4 is not ipv6|, %{schema: schema} do
      refute valid?(schema, "127.0.0.1")
    end

    test ~s|ipv4 segment must have 4 octets|, %{schema: schema} do
      refute valid?(schema, "1:2:3:4:1.2.3")
    end

    test ~s|leading whitespace is invalid|, %{schema: schema} do
      refute valid?(schema, "  ::1")
    end

    test ~s|trailing whitespace is invalid|, %{schema: schema} do
      refute valid?(schema, "::1  ")
    end

    test ~s|netmask is not a part of ipv6 address|, %{schema: schema} do
      refute valid?(schema, "fe80::/64")
    end

    test ~s|zone id is not a part of ipv6 address|, %{schema: schema} do
      refute valid?(schema, "fe80::a%eth1")
    end

    test ~s|a long valid ipv6|, %{schema: schema} do
      assert valid?(schema, "1000:1000:1000:1000:1000:1000:255.255.255.255")
    end

    test ~s|a long invalid ipv6, below length limit, first|, %{schema: schema} do
      refute valid?(schema, "100:100:100:100:100:100:255.255.255.255.255")
    end

    test ~s|a long invalid ipv6, below length limit, second|, %{schema: schema} do
      refute valid?(schema, "100:100:100:100:100:100:100:255.255.255.255")
    end
  end
end
