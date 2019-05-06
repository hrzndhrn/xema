defmodule Xema.StructTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  defmodule Foo do
    defstruct [:bar]
  end

  defmodule Bar do
    defstruct [:foo]
  end

  describe "empty struct schema" do
    setup do
      %{schema: Xema.new(:struct)}
    end

    test "validate/2 with a struct", %{schema: schema} do
      assert validate(schema, %Foo{}) == :ok
    end

    test "validate/2 with a string", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: ~s|Expected :struct, got "foo".|,
                 reason: %{type: :struct, value: "foo"}
               }
             } = validate(schema, "foo")
    end

    test "validate/2 with a map", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected :struct, got %{}.",
                 reason: %{type: :struct, value: %{}}
               }
             } = validate(schema, %{})
    end
  end

  describe "struct schema with keyword module" do
    setup do
      %{schema: Xema.new({:struct, module: Foo})}
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, %Foo{}) == :ok
    end

    test "validate/2 with invalid struct", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected Xema.StructTest.Foo, got %Xema.StructTest.Bar{foo: nil}.",
                 reason: %{module: Xema.StructTest.Foo, value: %Xema.StructTest.Bar{foo: nil}}
               }
             } = validate(schema, %Bar{})
    end
  end

  describe "sturct schema for regex" do
    setup do
      %{schema: Xema.new({:struct, module: Regex})}
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, ~r/.*/) == :ok
    end

    test "validate/2 with invalid struct", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 message: "Expected Regex, got %Xema.StructTest.Bar{foo: nil}.",
                 reason: %{module: Regex, value: %Xema.StructTest.Bar{foo: nil}}
               }
             } = validate(schema, %Bar{})
    end
  end
end
