defmodule Xema.StringTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  describe "'string' schema:" do
    setup do
      %{schema: Xema.new(:string)}
    end

    test "validate/2 with a string", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end

    test "validate/2 with a number", %{schema: schema} do
      expected = {:error, %{type: :string, value: 1}}

      assert validate(schema, 1) == expected
    end

    test "validate/2 with nil", %{schema: schema} do
      expected = {:error, %{type: :string, value: nil}}

      assert validate(schema, nil) == expected
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
      assert validate(schema, "f") == {:error, %{min_length: 3, value: "f"}}
    end

    test "validate/2 with a too long string", %{schema: schema} do
      assert validate(schema, "foobar") ==
               {:error, %{max_length: 4, value: "foobar"}}
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
      assert validate(schema, "a to a") ==
               {:error, %{value: "a to a", pattern: ~r/^.+match.+$/}}
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
      assert validate(schema, "a to a") ==
               {:error, %{value: "a to a", pattern: ~r/^.+match.+$/}}
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
      expected = {:error, %{enum: ["one", "two"], value: "foo"}}

      assert validate(schema, "foo") == expected
    end
  end
end
