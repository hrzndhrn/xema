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

  defmodule Baz do
    use Xema

    xema do
      field :a, [:integer, nil]
      field :b, :list, default: []
      field :c, [:integer, nil], default: 1
      field :d, [:integer, nil]
    end
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
                 reason: %{type: :struct, value: "foo"}
               } = error
             } = validate(schema, "foo")

      assert Exception.message(error) == ~s|Expected :struct, got "foo".|
    end

    test "validate/2 with a map", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{type: :struct, value: %{}}
               } = error
             } = validate(schema, %{})

      assert Exception.message(error) == "Expected :struct, got %{}."
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
                 reason: %{module: Xema.StructTest.Foo, value: %Xema.StructTest.Bar{foo: nil}}
               } = error
             } = validate(schema, %Bar{})

      assert Exception.message(error) ==
               "Expected Xema.StructTest.Foo, got %Xema.StructTest.Bar{foo: nil}."
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
                 reason: %{module: Regex, value: %Xema.StructTest.Bar{foo: nil}}
               } = error
             } = validate(schema, %Bar{})

      assert Exception.message(error) == "Expected Regex, got %Xema.StructTest.Bar{foo: nil}."
    end
  end

  describe "struct with default value" do
    test "list not nil" do
      baz = %Baz{}
      assert baz.a == nil
      assert baz.b == []
      assert baz.c == 1
      assert baz.d == nil

      assert Baz.valid?(baz)
    end
  end
end
