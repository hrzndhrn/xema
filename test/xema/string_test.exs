defmodule Xema.StringTest do

  use ExUnit.Case, async: true

  import Xema
  import Xema.TestSupport

  describe "'string' schema" do
    setup do
      %{schema: xema(:string)}
    end

    test "type", %{schema: schema} do
      assert type(schema, :string)
      assert as(schema, :string)
    end

    test "validate/2 with a string", %{schema: schema},
      do: assert validate(schema, "foo") == :ok

    test "validate/2 with a number", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :string}}
      assert validate(schema, 1) == expected
    end

    test "validate/2 with nil", %{schema: schema} do
      expected = {:error, %{reason: :wrong_type, type: :string}}
      assert validate(schema, nil) == expected
    end

    test "is_valid?/2 with a valid value", %{schema: schema},
      do: assert is_valid?(schema, "foo")

    test "is_valid?/2 with an invalid value", %{schema: schema},
      do: refute is_valid?(schema, [])
  end

  describe "'string' schema with restricted length" do
    setup do
      %{schema: xema(:string, min_length: 3, max_length: 4)}
    end

    test "validate/2 with a proper string", %{schema: schema},
      do: assert validate(schema, "foo") == :ok

    test "validate/2 with a too short string", %{schema: schema} do
      expected = {:error, %{min_length: 3, reason: :too_short}}
      assert validate(schema, "f") == expected
    end

    test "validate/2 with a too long string", %{schema: schema} do
      expected = {:error, %{max_length: 4, reason: :too_long}}
      assert validate(schema, "foobar") == expected
    end
  end

  describe "'string' schema with pattern" do
    setup do
      %{schema: xema(:string, pattern: ~r/^.+match.+$/)}
    end

    test "validate/2 with a matching string", %{schema: schema},
      do: assert validate(schema, "a match a") == :ok

    test "validate/2 with a none matching string", %{schema: schema} do
      regex = ~r/^.+match.+$/
      expected = {:error, %{reason: :no_match, pattern: regex}}
      assert validate(schema, "a to a") == expected
    end
  end

  describe "'string' schema with enum" do
    setup do
      %{schema: xema(:string, enum: ["one", "two"])}
    end

    test "validate/2 with a value from the enum", %{schema: schema},
      do: assert validate(schema, "two") == :ok

    test "validate/2 with a value that is not in the enum", %{schema: schema} do
      expected = {:error, %{
        reason: :not_in_enum,
        enum: ["one", "two"],
        element: "foo"}}
      assert validate(schema, "foo") == expected
    end
  end
end
