defmodule Draft7.Optional.Format.UriTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "validation of URIs" do
    setup do
      %{schema: Xema.new(:format, :uri)}
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
end
