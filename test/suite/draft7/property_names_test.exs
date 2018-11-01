defmodule Draft7.PropertyNamesTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "propertyNames validation" do
    setup do
      %{schema: Xema.new(property_names: [max_length: 3])}
    end

    test "all property names valid", %{schema: schema} do
      data = %{f: %{}, foo: %{}}
      assert valid?(schema, data)
    end

    test "some property names invalid", %{schema: schema} do
      data = %{foo: %{}, foobar: %{}}
      refute valid?(schema, data)
    end

    test "object without properties is valid", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end

    test "ignores arrays", %{schema: schema} do
      data = [1, 2, 3, 4]
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

  describe "propertyNames with boolean schema true" do
    setup do
      %{schema: Xema.new(property_names: true)}
    end

    test "object with any properties is valid", %{schema: schema} do
      data = %{foo: 1}
      assert valid?(schema, data)
    end

    test "empty object is valid", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end
  end

  describe "propertyNames with boolean schema false" do
    setup do
      %{schema: Xema.new(property_names: false)}
    end

    test "object with any properties is invalid", %{schema: schema} do
      data = %{foo: 1}
      refute valid?(schema, data)
    end

    test "empty object is valid", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end
  end
end
