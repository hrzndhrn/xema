defmodule JsonSchemaTestSuite.Draft7.Optional.Format.Hostname do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "validation of host names" do
    setup do
      %{schema: Xema.from_json_schema(%{"format" => "hostname"})}
    end

    test "a valid host name", %{schema: schema} do
      assert valid?(schema, "www.example.com")
    end

    test "a valid punycoded IDN hostname", %{schema: schema} do
      assert valid?(schema, "xn--4gbwdl.xn--wgbh1c")
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
