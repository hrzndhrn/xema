defmodule Suite.Draft4.RequiredTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "required validation" do
    setup do
      %{
        schema:
          Xema.new(
            :any,
            properties: %{"bar" => :any, "foo" => :any},
            required: ["foo"]
          )
      }
    end

    @tag :draft4
    @tag :required
    test "present required property is valid", %{schema: schema} do
      data = %{"foo" => 1}
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :required
    test "non-present required property is invalid", %{schema: schema} do
      data = %{"bar" => 1}
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :required
    test "ignores arrays", %{schema: schema} do
      data = []
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :required
    test "ignores strings", %{schema: schema} do
      data = ""
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :required
    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert is_valid?(schema, data)
    end
  end

  describe "required default validation" do
    setup do
      %{schema: Xema.new(:properties, %{"foo" => :any})}
    end

    @tag :draft4
    @tag :required
    test "not required by default", %{schema: schema} do
      data = %{}
      assert is_valid?(schema, data)
    end
  end
end
