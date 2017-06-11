defmodule Xema.StringTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  test "simple string schema" do
    schema = Xema.create(:string)

    assert schema.type == :string
    assert schema.properties == %Xema.String{
      max_length: nil,
      min_length: nil,
      pattern: nil
    }

    assert is_valid?(schema, "foo")
    refute is_valid?(schema, 1)
    refute is_valid?(schema, [])
    refute is_valid?(schema, %{})
    refute is_valid?(schema, :atom)

    assert validate(schema, "foo") == :ok
    assert validate(schema, 1) == {:error, {:type, :string}}
    assert validate(schema, []) == {:error, {:type, :string}}
    assert validate(schema, %{}) == {:error, {:type, :string}}
    assert validate(schema, :atom) == {:error, {:type, :string}}
  end

  test "string schema with min length" do
    schema = Xema.create(:string, min_length: 5)

    assert schema.type == :string
    assert schema.properties == %Xema.String{max_length: nil, min_length: 5}

    refute is_valid?(schema, "foo")
    assert is_valid?(schema, "foofoo")

    assert validate(schema, "foofoo") == :ok
    assert validate(schema, "foo") == {:error, {:min_length, 5}}
  end

  test "string schema with max length" do
    schema = Xema.create(:string, max_length: 5)

    assert schema.type == :string
    assert schema.properties == %Xema.String{max_length: 5, min_length: nil}

    assert is_valid?(schema, "foo")
    refute is_valid?(schema, "foofoo")

    assert validate(schema, "foo") == :ok
    assert validate(schema, "foofoo") == {:error, {:max_length, 5}}
  end

  test "string schema with min and max length" do
    schema = Xema.create(:string, min_length: 2, max_length: 3)

    assert schema.type == :string
    assert schema.properties == %Xema.String{min_length: 2, max_length: 3}

    refute is_valid?(schema, "a")
    assert is_valid?(schema, "ab")
    assert is_valid?(schema, "abc")
    refute is_valid?(schema, "abcd")

    assert validate(schema, "a") == {:error, {:min_length, 2}}
    assert validate(schema, "ab") == :ok
    assert validate(schema, "abc") == :ok
    assert validate(schema, "abcd") == {:error, {:max_length, 3}}
  end

  test "string schema with pattern" do
    regex = ~r/^.+match.+$/
    schema = Xema.create(:string, pattern: regex)

    assert schema.type == :string
    assert schema.properties == %Xema.String{pattern: regex}

    assert is_valid?(schema, "a match a")
    refute is_valid?(schema, "a to a")

    assert validate(schema, "a match a") == :ok
    assert validate(schema, "a to a") == {:error, {:pattern, regex}}
  end

  test "string schema with pattern, min length and max length" do
    regex = ~r/^.+b.+$/
    schema = Xema.create(:string, pattern: regex, min_length: 3, max_length: 4)

    assert schema.type == :string
    assert schema.properties == %Xema.String{
      min_length: 3,
      max_length: 4,
      pattern: regex
    }

    refute is_valid?(schema, "a")
    refute is_valid?(schema, "ab")
    assert is_valid?(schema, "abc")
    refute is_valid?(schema, "axc")
    assert is_valid?(schema, "abcd")
    refute is_valid?(schema, "axcd")
    refute is_valid?(schema, "abcde")
    refute is_valid?(schema, "axcde")

    assert validate(schema, "a") == {:error, {:min_length, 3}}
    assert validate(schema, "ab") == {:error, {:min_length, 3}}
    assert validate(schema, "abc") == :ok
    assert validate(schema, "axc") == {:error, {:pattern, regex}}
    assert validate(schema, "abcd") == :ok
    assert validate(schema, "axcd") == {:error, {:pattern, regex}}
    assert validate(schema, "abcde") == {:error, {:max_length, 4}}
  end

  #
  describe "Semantic validation with 'format'" do
    # 2017-06-11
    # http://json-schema.org/latest/json-schema-validation.html#rfc.section.8

    @tag :skip
    test "date-time"

    test "email" do
      schema = Xema.create(:string, format: :email)

      assert schema.type == :string
      assert schema.properties == %Xema.String{format: :email}

      assert is_valid?(schema, "test@mars.net")
      refute is_valid?(schema, "not an email")
    end

    test "hostname" do
      schema = Xema.create(:string, format: :hostname)

      assert schema.type == :string
      assert schema.properties == %Xema.String{format: :hostname}

      assert is_valid?(schema, "localhost")
      assert is_valid?(schema, "elixirforum.com")
      refute is_valid?(schema, "test mars.net")
      refute is_valid?(schema, "not a hostname")
    end

    test "ipv4" do
      schema = Xema.create(:string, format: :ipv4)

      assert schema.type == :string
      assert schema.properties == %Xema.String{format: :ipv4}

      assert is_valid?(schema, "127.0.0.1")
      assert is_valid?(schema, "192.168.0.1/3")
      assert is_valid?(schema, "927.0.0.1")
      refute is_valid?(schema, "not an ipv4")
    end

    test "ipv6" do
      schema = Xema.create(:string, format: :ipv6)

      assert schema.type == :string
      assert schema.properties == %Xema.String{format: :ipv6}

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
