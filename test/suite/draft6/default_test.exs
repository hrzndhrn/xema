defmodule Draft6.DefaultTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "invalid type for default" do
    setup do
      %{schema: Xema.new(properties: %{foo: {:integer, [default: []]}})}
    end

    test "valid when property is specified", %{schema: schema} do
      data = %{foo: 13}
      assert valid?(schema, data)
    end

    test "still valid when the invalid default is used", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end
  end

  describe "invalid string value for default" do
    setup do
      %{
        schema: Xema.new(properties: %{bar: {:string, [default: "bad", min_length: 4]}})
      }
    end

    test "valid when property is specified", %{schema: schema} do
      data = %{bar: "good"}
      assert valid?(schema, data)
    end

    test "still valid when the invalid default is used", %{schema: schema} do
      data = %{}
      assert valid?(schema, data)
    end
  end
end
