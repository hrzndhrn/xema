defmodule Draft4.EnumTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "simple enum validation" do
    setup do
      %{schema: Xema.new(:enum, [1, 2, 3])}
    end

    @tag :draft4
    @tag :enum
    test "one of the enum is valid", %{schema: schema} do
      data = 1
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :enum
    test "something else is invalid", %{schema: schema} do
      data = 4
      refute is_valid?(schema, data)
    end
  end

  describe "heterogeneous enum validation" do
    setup do
      %{schema: Xema.new(:enum, [6, "foo", [], true, %{foo: 12}])}
    end

    @tag :draft4
    @tag :enum
    test "one of the enum is valid", %{schema: schema} do
      data = []
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :enum
    test "something else is invalid", %{schema: schema} do
      data = nil
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :enum
    test "objects are deep compared", %{schema: schema} do
      data = %{foo: false}
      refute is_valid?(schema, data)
    end
  end

  describe "enums in properties" do
    setup do
      %{
        schema:
          Xema.new(
            :map,
            properties: %{bar: {:enum, ["bar"]}, foo: {:enum, ["foo"]}},
            required: ["bar"]
          )
      }
    end

    @tag :draft4
    @tag :enum
    test "both properties are valid", %{schema: schema} do
      data = %{bar: "bar", foo: "foo"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :enum
    test "missing optional property is valid", %{schema: schema} do
      data = %{bar: "bar"}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :enum
    test "missing required property is invalid", %{schema: schema} do
      data = %{foo: "foo"}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :enum
    test "missing all properties is invalid", %{schema: schema} do
      data = %{}
      refute is_valid?(schema, data)
    end
  end
end
