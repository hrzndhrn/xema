defmodule JsonSchemaTestSuite.Draft4.Optional.Format.HostnameTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|validation of host names| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"format" => "hostname"},
            draft: "draft4",
            atom: :force
          )
      }
    end

    test ~s|a valid host name|, %{schema: schema} do
      assert valid?(schema, "www.example.com")
    end

    test ~s|a host name starting with an illegal character|, %{schema: schema} do
      refute valid?(schema, "-a-host-name-that-starts-with--")
    end

    test ~s|a host name containing illegal characters|, %{schema: schema} do
      refute valid?(schema, "not_a_valid_host_name")
    end

    test ~s|a host name with a component too long|, %{schema: schema} do
      refute valid?(
               schema,
               "a-vvvvvvvvvvvvvvvveeeeeeeeeeeeeeeerrrrrrrrrrrrrrrryyyyyyyyyyyyyyyy-long-host-name-component"
             )
    end

    test ~s|starts with hyphen|, %{schema: schema} do
      refute valid?(schema, "-hostname")
    end

    test ~s|ends with hyphen|, %{schema: schema} do
      refute valid?(schema, "hostname-")
    end

    test ~s|starts with underscore|, %{schema: schema} do
      refute valid?(schema, "_hostname")
    end

    test ~s|ends with underscore|, %{schema: schema} do
      refute valid?(schema, "hostname_")
    end

    test ~s|contains underscore|, %{schema: schema} do
      refute valid?(schema, "host_name")
    end

    test ~s|maximum label length|, %{schema: schema} do
      assert valid?(schema, "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijk.com")
    end

    test ~s|exceeds maximum label length|, %{schema: schema} do
      refute valid?(
               schema,
               "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijkl.com"
             )
    end
  end
end
