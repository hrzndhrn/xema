defmodule Draft7.MaxPropertiesTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "maxProperties validation" do
    setup do
      %{schema: Xema.new(max_properties: 2)}
    end

    test "shorter is valid", %{schema: schema} do
      data = %{foo: 1}
      assert valid?(schema, data)
    end

    test "exact length is valid", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      assert valid?(schema, data)
    end

    test "too long is invalid", %{schema: schema} do
      data = %{bar: 2, baz: 3, foo: 1}
      refute valid?(schema, data)
    end

    test "ignores arrays", %{schema: schema} do
      data = [1, 2, 3]
      assert valid?(schema, data)
    end

    test "ignores strings", %{schema: schema} do
      data = "foobar"
      assert valid?(schema, data)
    end

    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert valid?(schema, data)
    end
  end
end
