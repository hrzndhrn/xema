defmodule Xema.MultiTypeTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  test "&new/1 called with a wrong type list raised an exception" do
    assert_raise Xema.SchemaError, "Invalid types [:foo].", fn ->
      Xema.new([:string, :foo])
    end
  end

  describe "schema with type string or nil:" do
    setup do
      %{schema: Xema.new([:string, nil], min_length: 5)}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "foobar") == :ok
    end

    test "with an invalid string", %{schema: schema} do
      assert validate(schema, "foo") == {:error, %{min_length: 5, value: "foo"}}
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "with integer", %{schema: schema} do
      assert validate(schema, 42) ==
               {:error, %{type: [:string, nil], value: 42}}
    end
  end

  describe "property with type number or nil:" do
    setup do
      %{schema: Xema.new(:properties, %{foo: [:number, nil]})}
    end

    test "with a number", %{schema: schema} do
      assert validate(schema, %{foo: 42}) == :ok
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, %{foo: nil}) == :ok
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, %{foo: "foo"}) ==
               {:error,
                %{properties: %{foo: %{type: [:number, nil], value: "foo"}}}}
    end
  end

  describe "keyword allow:" do
    setup do
      %{schema: Xema.new(:string, allow: nil)}
    end

    test "with a string", %{schema: schema} do
      assert validate(schema, "string") == :ok
    end

    test "with nil", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "with a number", %{schema: schema} do
      assert validate(schema, 42) ==
               {:error, %{type: [:string, nil], value: 42}}
    end
  end
end
