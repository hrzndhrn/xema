defmodule Xema.StringTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  @combining_acute <<0x0301::utf8>>
  @zero_width_joiner <<0x200D::utf8>>
  @grinning_face <<0x1F600::utf8>>

  describe "'string' schema:" do
    setup do
      %{schema: Xema.new(:string)}
    end

    test "validate/2 with a string", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end

    test "validate/2 with a number", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: :string, value: 1}
               } = error
             } = validate(schema, 1)

      assert Exception.message(error) == "Expected :string, got 1."
    end

    test "validate/2 with nil", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: :string, value: nil}
               } = error
             } = validate(schema, nil)

      assert Exception.message(error) == "Expected :string, got nil."
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, "foo")
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute valid?(schema, [])
    end
  end

  describe "string schema with restricted length:" do
    setup do
      %{schema: Xema.new({:string, min_length: 3, max_length: 4})}
    end

    test "validate/2 with a proper string", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end

    test "validate/2 with a too short string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{min_length: 3, value: "f"}
               } = error
             } = validate(schema, "f")

      assert Exception.message(error) == ~s|Expected minimum length of 3, got "f".|
    end

    test "validate/2 with a too long string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{max_length: 4, value: "foobar"}
               } = error
             } = validate(schema, "foobar")

      assert Exception.message(error) == ~s|Expected maximum length of 4, got "foobar".|
    end
  end

  describe "string schema with length measured in code points:" do
    setup do
      %{schema: Xema.new({:string, min_length: 3, max_length: 4})}
    end

    test "validate/2 with combining marks over the maximum", %{schema: schema} do
      value = "a" <> String.duplicate(@combining_acute, 10)

      assert {:error, %ValidationError{reason: %{max_length: 4}}} = validate(schema, value)
    end

    test "validate/2 with an emoji sequence over the maximum", %{schema: schema} do
      family =
        Enum.join([<<0x1F468::utf8>>, <<0x1F469::utf8>>, <<0x1F467::utf8>>], @zero_width_joiner)

      assert {:error, %ValidationError{reason: %{max_length: 4}}} = validate(schema, family)
    end

    test "validate/2 with a single code point under the minimum", %{schema: schema} do
      assert {:error, %ValidationError{reason: %{min_length: 3}}} =
               validate(schema, @grinning_face)
    end

    test "validate/2 counts astral code points as one each", %{schema: schema} do
      assert validate(schema, String.duplicate(@grinning_face, 3)) == :ok
    end
  end

  describe "string schema length with malformed utf8:" do
    setup do
      %{schema: Xema.new({:string, max_length: 4})}
    end

    # these all agree with String.length/1, which is what the keywords used before

    test "validate/2 counts a byte that is not valid utf8 as one", %{schema: schema} do
      assert validate(schema, <<"ab", 0xFF>>) == :ok
    end

    test "validate/2 counts each byte of a truncated sequence", %{schema: schema} do
      assert validate(schema, <<0xE2, 0x82>>) == :ok
    end

    test "validate/2 counts lone continuation bytes", %{schema: schema} do
      assert validate(schema, <<0x80, 0x80>>) == :ok
    end

    test "validate/2 counts each byte of an overlong encoding", %{schema: schema} do
      assert validate(schema, <<0xC0, 0xAF>>) == :ok
    end

    test "validate/2 with malformed bytes over the maximum", %{schema: schema} do
      assert {:error, %ValidationError{reason: %{max_length: 4}}} =
               validate(schema, <<0xFF, 0xFF, 0xFF, 0xFF, 0xFF>>)
    end
  end

  describe "string schema with a pattern:" do
    setup do
      %{schema: Xema.new({:string, pattern: ~r/^.+match.+$/})}
    end

    test "validate/2 with a matching string", %{schema: schema} do
      assert validate(schema, "a match a") == :ok
    end

    test "validate/2 with a none matching string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{value: "a to a", pattern: pattern}
               } = error
             } = validate(schema, "a to a")

      assert Regex.source(pattern) == "^.+match.+$"

      assert Exception.message(error) ==
               ~s|Pattern ~r/^.+match.+$/ does not match value "a to a".|
    end
  end

  describe "string schema with a string as pattern:" do
    setup do
      %{schema: Xema.new({:string, pattern: "^.+match.+$"})}
    end

    test "validate/2 with a matching string", %{schema: schema} do
      assert validate(schema, "a match a") == :ok
    end

    test "validate/2 with a none matching string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{value: "a to a", pattern: pattern}
               } = error
             } = validate(schema, "a to a")

      assert Regex.source(pattern) == "^.+match.+$"

      assert Exception.message(error) ==
               ~s|Pattern ~r/^.+match.+$/ does not match value "a to a".|
    end
  end

  describe "string schema with enum:" do
    setup do
      %{schema: Xema.new({:string, enum: ["one", "two"]})}
    end

    test "validate/2 with a value from the enum", %{schema: schema} do
      assert validate(schema, "two") == :ok
    end

    test "validate/2 with a value that is not in the enum", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{enum: ["one", "two"], value: "foo"}
               } = error
             } = assert(validate(schema, "foo"))

      assert Exception.message(error) == ~s|Value "foo" is not defined in enum.|
    end
  end
end
