defmodule Draft4.MinPropertiesTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "minProperties validation" do
    setup do
      %{schema: Xema.new(:min_properties, 1)}
    end

    test "longer is valid", %{schema: schema} do
      data = %{bar: 2, foo: 1}
      assert is_valid?(schema, data)
    end

    test "exact length is valid", %{schema: schema} do
      data = %{foo: 1}
      assert is_valid?(schema, data)
    end

    test "too short is invalid", %{schema: schema} do
      data = %{}
      refute is_valid?(schema, data)
    end

    test "ignores arrays", %{schema: schema} do
      data = []
      assert is_valid?(schema, data)
    end

    test "ignores strings", %{schema: schema} do
      data = ""
      assert is_valid?(schema, data)
    end

    test "ignores other non-objects", %{schema: schema} do
      data = 12
      assert is_valid?(schema, data)
    end
  end
end
