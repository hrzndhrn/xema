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
end
