defmodule JsonSchemaTestSuite.Draft4.Optional.FormatTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of date-time strings" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "date-time"},
            draft: "draft4"
          )
      }
    end

    test "a valid date-time string", %{schema: schema} do
      assert valid?(schema, "1963-06-19T08:30:06.283185Z")
    end

    test "a valid date-time string without second fraction", %{schema: schema} do
      assert valid?(schema, "1963-06-19T08:30:06Z")
    end

    test "a valid date-time string with plus offset", %{schema: schema} do
      assert valid?(schema, "1937-01-01T12:00:27.87+00:20")
    end

    test "a valid date-time string with minus offset", %{schema: schema} do
      assert valid?(schema, "1990-12-31T15:59:50.123-08:00")
    end

    test "a invalid day in date-time string", %{schema: schema} do
      refute valid?(schema, "1990-02-31T15:59:60.123-08:00")
    end

    test "an invalid offset in date-time string", %{schema: schema} do
      refute valid?(schema, "1990-12-31T15:59:60-24:00")
    end

    test "an invalid date-time string", %{schema: schema} do
      refute valid?(schema, "06/19/1963 08:30:06 PST")
    end

    test "case-insensitive T and Z", %{schema: schema} do
      assert valid?(schema, "1963-06-19t08:30:06.283185z")
    end

    test "only RFC3339 not all of ISO 8601 are valid", %{schema: schema} do
      refute valid?(schema, "2013-350T01:01:01")
    end
  end

  describe "validation of URIs" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "uri"},
            draft: "draft4"
          )
      }
    end

    test "a valid URL with anchor tag", %{schema: schema} do
      assert valid?(schema, "http://foo.bar/?baz=qux#quux")
    end

    test "a valid URL with anchor tag and parantheses", %{schema: schema} do
      assert valid?(schema, "http://foo.com/blah_(wikipedia)_blah#cite-1")
    end

    test "a valid URL with URL-encoded stuff", %{schema: schema} do
      assert valid?(schema, "http://foo.bar/?q=Test%20URL-encoded%20stuff")
    end

    test "a valid puny-coded URL ", %{schema: schema} do
      assert valid?(schema, "http://xn--nw2a.xn--j6w193g/")
    end

    test "a valid URL with many special characters", %{schema: schema} do
      assert valid?(schema, "http://-.~_!$&'()*+,;=:%40:80%2f::::::@example.com")
    end

    test "a valid URL based on IPv4", %{schema: schema} do
      assert valid?(schema, "http://223.255.255.254")
    end

    test "a valid URL with ftp scheme", %{schema: schema} do
      assert valid?(schema, "ftp://ftp.is.co.za/rfc/rfc1808.txt")
    end

    test "a valid URL for a simple text file", %{schema: schema} do
      assert valid?(schema, "http://www.ietf.org/rfc/rfc2396.txt")
    end

    test "a valid URL ", %{schema: schema} do
      assert valid?(schema, "ldap://[2001:db8::7]/c=GB?objectClass?one")
    end

    test "a valid mailto URI", %{schema: schema} do
      assert valid?(schema, "mailto:John.Doe@example.com")
    end

    test "a valid newsgroup URI", %{schema: schema} do
      assert valid?(schema, "news:comp.infosystems.www.servers.unix")
    end

    test "a valid tel URI", %{schema: schema} do
      assert valid?(schema, "tel:+1-816-555-1212")
    end

    test "a valid URN", %{schema: schema} do
      assert valid?(schema, "urn:oasis:names:specification:docbook:dtd:xml:4.1.2")
    end

    test "an invalid protocol-relative URI Reference", %{schema: schema} do
      refute valid?(schema, "//foo.bar/?baz=qux#quux")
    end

    test "an invalid relative URI Reference", %{schema: schema} do
      refute valid?(schema, "/abc")
    end

    test "an invalid URI", %{schema: schema} do
      refute valid?(schema, "\\\\WINDOWS\\fileshare")
    end

    test "an invalid URI though valid URI reference", %{schema: schema} do
      refute valid?(schema, "abc")
    end

    test "an invalid URI with spaces", %{schema: schema} do
      refute valid?(schema, "http:// shouldfail.com")
    end

    test "an invalid URI with spaces and missing scheme", %{schema: schema} do
      refute valid?(schema, ":// should fail")
    end
  end

  describe "validation of e-mail addresses" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "email"},
            draft: "draft4"
          )
      }
    end

    test "a valid e-mail address", %{schema: schema} do
      assert valid?(schema, "joe.bloggs@example.com")
    end

    test "an invalid e-mail address", %{schema: schema} do
      refute valid?(schema, "2962")
    end
  end

  describe "validation of IP addresses" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "ipv4"},
            draft: "draft4"
          )
      }
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

  describe "validation of IPv6 addresses" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "ipv6"},
            draft: "draft4"
          )
      }
    end

    test "a valid IPv6 address", %{schema: schema} do
      assert valid?(schema, "::1")
    end

    test "an IPv6 address with out-of-range values", %{schema: schema} do
      refute valid?(schema, "12345::")
    end

    test "an IPv6 address with too many components", %{schema: schema} do
      refute valid?(schema, "1:1:1:1:1:1:1:1:1:1:1:1:1:1:1:1")
    end

    test "an IPv6 address containing illegal characters", %{schema: schema} do
      refute valid?(schema, "::laptop")
    end
  end

  describe "validation of host names" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "hostname"},
            draft: "draft4"
          )
      }
    end

    test "a valid host name", %{schema: schema} do
      assert valid?(schema, "www.example.com")
    end

    test "a host name starting with an illegal character", %{schema: schema} do
      refute valid?(schema, "-a-host-name-that-starts-with--")
    end

    test "a host name containing illegal characters", %{schema: schema} do
      refute valid?(schema, "not_a_valid_host_name")
    end

    test "a host name with a component too long", %{schema: schema} do
      refute valid?(
               schema,
               "a-vvvvvvvvvvvvvvvveeeeeeeeeeeeeeeerrrrrrrrrrrrrrrryyyyyyyyyyyyyyyy-long-host-name-component"
             )
    end
  end
end
