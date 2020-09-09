defmodule JsonSchemaTestSuite.Draft4.Optional.Format.UriTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of URIs| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "uri"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|a valid URL with anchor tag|, %{schema: schema} do
      assert valid?(schema, "http://foo.bar/?baz=qux#quux")
    end

    test ~s|a valid URL with anchor tag and parantheses|, %{schema: schema} do
      assert valid?(schema, "http://foo.com/blah_(wikipedia)_blah#cite-1")
    end

    test ~s|a valid URL with URL-encoded stuff|, %{schema: schema} do
      assert valid?(schema, "http://foo.bar/?q=Test%20URL-encoded%20stuff")
    end

    test ~s|a valid puny-coded URL |, %{schema: schema} do
      assert valid?(schema, "http://xn--nw2a.xn--j6w193g/")
    end

    test ~s|a valid URL with many special characters|, %{schema: schema} do
      assert valid?(schema, "http://-.~_!$&'()*+,;=:%40:80%2f::::::@example.com")
    end

    test ~s|a valid URL based on IPv4|, %{schema: schema} do
      assert valid?(schema, "http://223.255.255.254")
    end

    test ~s|a valid URL with ftp scheme|, %{schema: schema} do
      assert valid?(schema, "ftp://ftp.is.co.za/rfc/rfc1808.txt")
    end

    test ~s|a valid URL for a simple text file|, %{schema: schema} do
      assert valid?(schema, "http://www.ietf.org/rfc/rfc2396.txt")
    end

    test ~s|a valid URL |, %{schema: schema} do
      assert valid?(schema, "ldap://[2001:db8::7]/c=GB?objectClass?one")
    end

    test ~s|a valid mailto URI|, %{schema: schema} do
      assert valid?(schema, "mailto:John.Doe@example.com")
    end

    test ~s|a valid newsgroup URI|, %{schema: schema} do
      assert valid?(schema, "news:comp.infosystems.www.servers.unix")
    end

    test ~s|a valid tel URI|, %{schema: schema} do
      assert valid?(schema, "tel:+1-816-555-1212")
    end

    test ~s|a valid URN|, %{schema: schema} do
      assert valid?(schema, "urn:oasis:names:specification:docbook:dtd:xml:4.1.2")
    end

    test ~s|an invalid protocol-relative URI Reference|, %{schema: schema} do
      refute valid?(schema, "//foo.bar/?baz=qux#quux")
    end

    test ~s|an invalid relative URI Reference|, %{schema: schema} do
      refute valid?(schema, "/abc")
    end

    test ~s|an invalid URI|, %{schema: schema} do
      refute valid?(schema, "\\\\WINDOWS\\fileshare")
    end

    test ~s|an invalid URI though valid URI reference|, %{schema: schema} do
      refute valid?(schema, "abc")
    end

    test ~s|an invalid URI with spaces|, %{schema: schema} do
      refute valid?(schema, "http:// shouldfail.com")
    end

    test ~s|an invalid URI with spaces and missing scheme|, %{schema: schema} do
      refute valid?(schema, ":// should fail")
    end

    test ~s|an invalid URI with comma in scheme|, %{schema: schema} do
      refute valid?(schema, "bar,baz:foo")
    end
  end
end
