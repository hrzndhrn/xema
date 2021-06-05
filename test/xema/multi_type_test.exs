defmodule Xema.MultiTypeTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "schema with type string or nil:" do
    setup do
      %{schema: Xema.new({[:string, nil], min_length: 5})}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "foobar") == :ok
    end

    test "with an invalid string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{min_length: 5, value: "foo"}
               } = error
             } = validate(schema, "foo")

      assert Exception.message(error) == ~s|Expected minimum length of 5, got "foo".|
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "with integer", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: [:string, nil], value: 42}
               } = error
             } = validate(schema, 42)

      assert Exception.message(error) == "Expected [:string, nil], got 42."
    end
  end

  describe "property with type number or nil:" do
    setup do
      %{schema: Xema.new(properties: %{foo: [:number, nil]})}
    end

    test "with a number", %{schema: schema} do
      assert validate(schema, %{foo: 42}) == :ok
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, %{foo: nil}) == :ok
    end

    test "with a string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{properties: %{foo: %{type: [:number, nil], value: "foo"}}}
               } = error
             } = validate(schema, %{foo: "foo"})

      assert Exception.message(error) == ~s|Expected [:number, nil], got "foo", at [:foo].|
    end
  end

  describe "keyword allow:" do
    setup do
      %{schema: Xema.new({:string, allow: nil})}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "string") == :ok
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "with a number", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: [:string, nil], value: 42}
               } = error
             } = validate(schema, 42)

      assert Exception.message(error) == "Expected [:string, nil], got 42."
    end
  end

  describe "keyword allow: with multiple types" do
    setup do
      %{schema: Xema.new({[:string, :boolean], allow: nil})}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "string") == :ok
    end

    test "with a boolean value", %{schema: schema} do
      assert validate(schema, true) == :ok
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "with a number", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: [nil, :string, :boolean], value: 42}
               } = error
             } = validate(schema, 42)

      assert Exception.message(error) == "Expected [nil, :string, :boolean], got 42."
    end
  end

  describe "keyword allow: list" do
    setup do
      %{schema: Xema.new({:string, allow: [nil]})}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "string") == :ok
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "with a number", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: [:string, nil], value: 42}
               } = error
             } = validate(schema, 42)

      assert Exception.message(error) == "Expected [:string, nil], got 42."
    end
  end

  describe "keyword allow: list with multiple types" do
    setup do
      %{schema: Xema.new({[:string, :boolean], allow: [nil]})}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "string") == :ok
    end

    test "with a boolean value", %{schema: schema} do
      assert validate(schema, true) == :ok
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "with a number", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: [nil, :string, :boolean], value: 42}
               } = error
             } = validate(schema, 42)

      assert Exception.message(error) == "Expected [nil, :string, :boolean], got 42."
    end
  end
end
