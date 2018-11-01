defmodule Draft4.Optional.FormatTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "validation of date-time strings" do
    setup do
      %{schema: Xema.new(format: :date_time)}
    end

    test "a valid date-time string", %{schema: schema} do
      data = "1963-06-19T08:30:06.283185Z"
      assert valid?(schema, data)
    end

    test "a valid date-time string without second fraction", %{schema: schema} do
      data = "1963-06-19T08:30:06Z"
      assert valid?(schema, data)
    end

    test "a valid date-time string with plus offset", %{schema: schema} do
      data = "1937-01-01T12:00:27.87+00:20"
      assert valid?(schema, data)
    end

    test "a valid date-time string with minus offset", %{schema: schema} do
      data = "1990-12-31T15:59:50.123-08:00"
      assert valid?(schema, data)
    end

    test "a invalid day in date-time string", %{schema: schema} do
      data = "1990-02-31T15:59:60.123-08:00"
      refute valid?(schema, data)
    end

    test "an invalid offset in date-time string", %{schema: schema} do
      data = "1990-12-31T15:59:60-24:00"
      refute valid?(schema, data)
    end

    test "an invalid date-time string", %{schema: schema} do
      data = "06/19/1963 08:30:06 PST"
      refute valid?(schema, data)
    end

    test "case-insensitive T and Z", %{schema: schema} do
      data = "1963-06-19t08:30:06.283185z"
      assert valid?(schema, data)
    end

    test "only RFC3339 not all of ISO 8601 are valid", %{schema: schema} do
      data = "2013-350T01:01:01"
      refute valid?(schema, data)
    end
  end

  describe "validation of URIs" do
    setup do
      %{schema: Xema.new(format: :uri)}
    end

    test "a valid URL with anchor tag", %{schema: schema} do
      data = "http://foo.bar/?baz=qux#quux"
      assert valid?(schema, data)
    end

    test "a valid URL with anchor tag and parantheses", %{schema: schema} do
      data = "http://foo.com/blah_(wikipedia)_blah#cite-1"
      assert valid?(schema, data)
    end

    test "a valid URL with URL-encoded stuff", %{schema: schema} do
      data = "http://foo.bar/?q=Test%20URL-encoded%20stuff"
      assert valid?(schema, data)
    end

    test "a valid puny-coded URL ", %{schema: schema} do
      data = "http://xn--nw2a.xn--j6w193g/"
      assert valid?(schema, data)
    end

    test "a valid URL with many special characters", %{schema: schema} do
      data = "http://-.~_!$&'()*+,;=:%40:80%2f::::::@example.com"
      assert valid?(schema, data)
    end

    test "a valid URL based on IPv4", %{schema: schema} do
      data = "http://223.255.255.254"
      assert valid?(schema, data)
    end

    test "a valid URL with ftp scheme", %{schema: schema} do
      data = "ftp://ftp.is.co.za/rfc/rfc1808.txt"
      assert valid?(schema, data)
    end

    test "a valid URL for a simple text file", %{schema: schema} do
      data = "http://www.ietf.org/rfc/rfc2396.txt"
      assert valid?(schema, data)
    end

    test "a valid URL ", %{schema: schema} do
      data = "ldap://[2001:db8::7]/c=GB?objectClass?one"
      assert valid?(schema, data)
    end

    test "a valid mailto URI", %{schema: schema} do
      data = "mailto:John.Doe@example.com"
      assert valid?(schema, data)
    end

    test "a valid newsgroup URI", %{schema: schema} do
      data = "news:comp.infosystems.www.servers.unix"
      assert valid?(schema, data)
    end

    test "a valid tel URI", %{schema: schema} do
      data = "tel:+1-816-555-1212"
      assert valid?(schema, data)
    end

    test "a valid URN", %{schema: schema} do
      data = "urn:oasis:names:specification:docbook:dtd:xml:4.1.2"
      assert valid?(schema, data)
    end

    test "an invalid protocol-relative URI Reference", %{schema: schema} do
      data = "//foo.bar/?baz=qux#quux"
      refute valid?(schema, data)
    end

    test "an invalid relative URI Reference", %{schema: schema} do
      data = "/abc"
      refute valid?(schema, data)
    end

    test "an invalid URI", %{schema: schema} do
      data = "\\\\WINDOWS\\fileshare"
      refute valid?(schema, data)
    end

    test "an invalid URI though valid URI reference", %{schema: schema} do
      data = "abc"
      refute valid?(schema, data)
    end

    test "an invalid URI with spaces", %{schema: schema} do
      data = "http:// shouldfail.com"
      refute valid?(schema, data)
    end

    test "an invalid URI with spaces and missing scheme", %{schema: schema} do
      data = ":// should fail"
      refute valid?(schema, data)
    end
  end

  describe "validation of e-mail addresses" do
    setup do
      %{schema: Xema.new(format: :email)}
    end

    test "a valid e-mail address", %{schema: schema} do
      data = "joe.bloggs@example.com"
      assert valid?(schema, data)
    end

    test "an invalid e-mail address", %{schema: schema} do
      data = "2962"
      refute valid?(schema, data)
    end
  end

  describe "validation of IP addresses" do
    setup do
      %{schema: Xema.new(format: :ipv4)}
    end

    test "a valid IP address", %{schema: schema} do
      data = "192.168.0.1"
      assert valid?(schema, data)
    end

    test "an IP address with too many components", %{schema: schema} do
      data = "127.0.0.0.1"
      refute valid?(schema, data)
    end

    test "an IP address with out-of-range values", %{schema: schema} do
      data = "256.256.256.256"
      refute valid?(schema, data)
    end

    test "an IP address without 4 components", %{schema: schema} do
      data = "127.0"
      refute valid?(schema, data)
    end

    test "an IP address as an integer", %{schema: schema} do
      data = "0x7f000001"
      refute valid?(schema, data)
    end
  end

  describe "validation of IPv6 addresses" do
    setup do
      %{schema: Xema.new(format: :ipv6)}
    end

    test "a valid IPv6 address", %{schema: schema} do
      data = "::1"
      assert valid?(schema, data)
    end

    test "an IPv6 address with out-of-range values", %{schema: schema} do
      data = "12345::"
      refute valid?(schema, data)
    end

    test "an IPv6 address with too many components", %{schema: schema} do
      data = "1:1:1:1:1:1:1:1:1:1:1:1:1:1:1:1"
      refute valid?(schema, data)
    end

    test "an IPv6 address containing illegal characters", %{schema: schema} do
      data = "::laptop"
      refute valid?(schema, data)
    end
  end

  describe "validation of host names" do
    setup do
      %{schema: Xema.new(format: :hostname)}
    end

    test "a valid host name", %{schema: schema} do
      data = "www.example.com"
      assert valid?(schema, data)
    end

    test "a host name starting with an illegal character", %{schema: schema} do
      data = "-a-host-name-that-starts-with--"
      refute valid?(schema, data)
    end

    test "a host name containing illegal characters", %{schema: schema} do
      data = "not_a_valid_host_name"
      refute valid?(schema, data)
    end

    test "a host name with a component too long", %{schema: schema} do
      data =
        "a-vvvvvvvvvvvvvvvveeeeeeeeeeeeeeeerrrrrrrrrrrrrrrryyyyyyyyyyyyyyyy-long-host-name-component"

      refute valid?(schema, data)
    end
  end
end
