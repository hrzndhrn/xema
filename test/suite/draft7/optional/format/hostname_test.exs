defmodule Draft7.Optional.Format.HostnameTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "validation of host names" do
    setup do
      %{schema: Xema.new(:format, :hostname)}
    end

    test "a valid host name", %{schema: schema} do
      data = "www.example.com"
      assert is_valid?(schema, data)
    end

    test "a valid punycoded IDN hostname", %{schema: schema} do
      data = "xn--4gbwdl.xn--wgbh1c"
      assert is_valid?(schema, data)
    end

    test "a host name starting with an illegal character", %{schema: schema} do
      data = "-a-host-name-that-starts-with--"
      refute is_valid?(schema, data)
    end

    test "a host name containing illegal characters", %{schema: schema} do
      data = "not_a_valid_host_name"
      refute is_valid?(schema, data)
    end

    test "a host name with a component too long", %{schema: schema} do
      data =
        "a-vvvvvvvvvvvvvvvveeeeeeeeeeeeeeeerrrrrrrrrrrrrrrryyyyyyyyyyyyyyyy-long-host-name-component"

      refute is_valid?(schema, data)
    end
  end
end
