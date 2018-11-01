defmodule Draft4.RequiredTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "required validation" do
    setup do
      %{
        schema: Xema.new(properties: %{bar: :any, foo: :any}, required: ["foo"])
      }
    end

    test "present required property is valid", %{schema: schema} do
      data = %{foo: 1}
      assert valid?(schema, data)
    end

    test "non-present required property is invalid", %{schema: schema} do
      data = %{bar: 1}
      refute valid?(schema, data)
    end

    test "ignores arrays", %{schema: schema} do
      data = []
      assert valid?(schema, data)
    end

    test "ignores strings", %{schema: schema} do
      data = ""
      assert valid?(schema, data)
    end

    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert valid?(schema, data)
    end
  end

  describe "required default validation" do
    setup do
      %{schema: Xema.new(properties: %{foo: :any})}
    end

    test "not required by default", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end
  end
end
