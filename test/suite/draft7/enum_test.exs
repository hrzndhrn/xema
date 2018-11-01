defmodule Draft7.EnumTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "simple enum validation" do
    setup do
      %{schema: Xema.new(enum: [1, 2, 3])}
    end

    test "one of the enum is valid", %{schema: schema} do
      data = 1
      assert valid?(schema, data)
    end

    test "something else is invalid", %{schema: schema} do
      data = 4
      refute valid?(schema, data)
    end
  end

  describe "heterogeneous enum validation" do
    setup do
      %{schema: Xema.new(enum: [6, "foo", [], true, %{foo: 12}])}
    end

    test "one of the enum is valid", %{schema: schema} do
      data = []
      assert valid?(schema, data)
    end

    test "something else is invalid", %{schema: schema} do
      data = nil
      refute valid?(schema, data)
    end

    test "objects are deep compared", %{schema: schema} do
      data = %{foo: false}
      refute valid?(schema, data)
    end
  end

  describe "enums in properties" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             [
               properties: %{bar: [enum: ["bar"]], foo: [enum: ["foo"]]},
               required: ["bar"]
             ]}
          )
      }
    end

    test "both properties are valid", %{schema: schema} do
      data = %{bar: "bar", foo: "foo"}
      assert valid?(schema, data)
    end

    test "missing optional property is valid", %{schema: schema} do
      data = %{bar: "bar"}
      assert valid?(schema, data)
    end

    test "missing required property is invalid", %{schema: schema} do
      data = %{foo: "foo"}
      refute valid?(schema, data)
    end

    test "missing all properties is invalid", %{schema: schema} do
      data = %{}
      refute valid?(schema, data)
    end
  end
end
