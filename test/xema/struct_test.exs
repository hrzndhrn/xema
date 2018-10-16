defmodule Xema.StructTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

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
      expected = {:error, %{type: :struct, value: "foo"}}

      assert validate(schema, "foo") == expected
    end

    test "validate/2 with a map", %{schema: schema} do
      expected = {:error, %{type: :struct, value: %{}}}

      assert validate(schema, %{}) == expected
    end
  end

  describe "struct schema with keyword module" do
    setup do
      %{schema: Xema.new(:struct, module: Foo)}
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, %Foo{}) == :ok
    end

    test "validate/2 with invalid struct", %{schema: schema} do
      expected =
        {:error,
         %{module: Xema.StructTest.Foo, value: %Xema.StructTest.Bar{foo: nil}}}

      assert validate(schema, %Bar{}) == expected
    end
  end

  describe "sturct schema for regex" do
    setup do
      %{schema: Xema.new(:struct, module: Regex)}
    end

    test "validate/2 with valid value", %{schema: schema} do
      assert validate(schema, ~r/.*/) == :ok
    end

    test "validate/2 with invalid struct", %{schema: schema} do
      expected =
        {:error, %{module: Regex, value: %Xema.StructTest.Bar{foo: nil}}}

      assert validate(schema, %Bar{}) == expected
    end
  end
end
