defmodule Xema.StringTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  setup do
    %{
      simple: Xema.create(:string),
      min: Xema.create(:string, min_length: 5),
      max: Xema.create(:string, max_length: 5),
      min_max: Xema.create(:string, min_length: 2, max_length: 3),
      pattern: Xema.create(:string, pattern: ~r/^.+match??.+$/)
    }
  end

  test "type and properties", schemas do
    assert schemas.simple.type == :string
  end

  describe "simple string schema" do
    test "with string", %{simple: schema},
      do: assert validate(schema, "foo") == :ok

    test "with integer", %{simple: schema} do
      expected = {:error, %{reason: :wrong_type, type: :string}}
      assert validate(schema, 1) == expected
    end
  end

  describe "string schema with min length" do
    test "with propper string", %{min: schema},
      do: assert validate(schema, "foofoo") == :ok

    test "with too short string", %{min: schema} do
      expected = {:error, %{reason: :too_short, min_length: 5}}
      assert validate(schema, "foo") == expected
    end
  end

  describe "string schema with max length" do
    test "with propper string", %{max: schema},
      do: assert validate(schema, "foo") == :ok

    test "with too long string", %{max: schema} do
      expected = {:error, %{reason: :too_long, max_length: 5}}
      assert validate(schema, "foofoo") == expected
    end
  end

  describe "string schema with min and max length" do
    test "with propper string", %{min_max: schema} do
      assert validate(schema, "ab") == :ok
      assert validate(schema, "abc") == :ok
    end

    test "with too short string", %{min_max: schema} do
      expected = {:error, %{reason: :too_short, min_length: 2}}
      assert validate(schema, "a") == expected
    end

    test "with too long string", %{min_max: schema} do
      expected = {:error, %{reason: :too_long, max_length: 3}}
      assert validate(schema, "abcd") == expected
    end
  end

  describe "string schema with pattern" do
    test "with propper string", %{pattern: schema},
      do: assert validate(schema, "a match?? a") == :ok

    test "with a none matching string", %{pattern: schema} do
      regex = ~r/^.+match??.+$/
      expected = {:error, %{reason: :no_match, pattern: regex}}
      assert validate(schema, "a to a") == expected
    end
  end

  describe "is_valid?/2" do
    test "with string", %{simple: schema},
      do: assert is_valid?(schema, "foo")

    test "with integer", %{simple: schema},
      do: refute is_valid?(schema, 1)
  end
end
