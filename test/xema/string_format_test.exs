defmodule Xema.StringFormatTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2] #, validate: 2]

  describe "Semantic validation with 'format'" do
    # 2017-06-11
    # http://json-schema.org/latest/json-schema-validation.html#rfc.section.8

    @tag :skip
    test "date-time"

    test "email" do
      schema = Xema.create(:string, format: :email)

      assert schema.type == :string
      assert schema.keywords == %Xema.String{format: :email}

      assert is_valid?(schema, "test@mars.net")
      refute is_valid?(schema, "not an email")
    end

    test "hostname" do
      schema = Xema.create(:string, format: :hostname)

      assert schema.type == :string
      assert schema.keywords == %Xema.String{format: :hostname}

      assert is_valid?(schema, "localhost")
      assert is_valid?(schema, "elixirforum.com")
      refute is_valid?(schema, "test mars.net")
      refute is_valid?(schema, "not a hostname")
    end

    test "ipv4" do
      schema = Xema.create(:string, format: :ipv4)

      assert schema.type == :string
      assert schema.keywords == %Xema.String{format: :ipv4}

      assert is_valid?(schema, "127.0.0.1")
      assert is_valid?(schema, "192.168.0.1/3")
      assert is_valid?(schema, "927.0.0.1")
      refute is_valid?(schema, "not an ipv4")
    end

    test "ipv6" do
      schema = Xema.create(:string, format: :ipv6)

      assert schema.type == :string
      assert schema.keywords == %Xema.String{format: :ipv6}

      assert is_valid?(schema, "::0")
      assert is_valid?(schema, "::10")
      assert is_valid?(schema, "ABCD:EF01:2345:6789:ABCD:EF01:2345:6789")
      assert is_valid?(schema, "2001:DB8:0:0:8:800:200C:417A")
      assert is_valid?(schema, "FF01:0:0:0:0:0:0:1010")
      assert is_valid?(schema, "0:0:0:0:0:0:0:1")
      assert is_valid?(schema, "0:0:0:0:0:0:0:0")
      assert is_valid?(schema, "FF01::101")
      assert is_valid?(schema, "0:0:0:0:0:0:13.1.68.3")
      assert is_valid?(schema, "0:0:0:0:0:FFFF:129.144.52.38")
      assert is_valid?(schema, "::13.1.68.3")
      assert is_valid?(schema, "FFFF:129.144.52.38")
      assert is_valid?(schema, "2001:0DB8:0000:CD30:0000:0000:0000:0000/60")
      assert is_valid?(schema, "2001:0DB8::CD30:0:0:0:0/60")
      assert is_valid?(schema, "2001:0DB8:0:CD30::/60")
    end

    @tag :skip
    test "TODO: ipv6" do
      schema = Xema.create(:string, format: :ipv6)

      refute is_valid?(schema, "2001:0DB8:0:CD3/60")
    end

    @tag :skip
    test "uri"

    @tag :skip
    test "uri-reference"

    @tag :skip
    test "uri-template"

    @tag :skip
    test "json-pointer"
  end
end
