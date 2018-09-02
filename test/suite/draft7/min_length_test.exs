defmodule Draft7.MinLengthTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "minLength validation" do
    setup do
      %{schema: Xema.new(:min_length, 2)}
    end

    test "longer is valid", %{schema: schema} do
      data = "foo"
      assert is_valid?(schema, data)
    end

    test "exact length is valid", %{schema: schema} do
      data = "fo"
      assert is_valid?(schema, data)
    end

    test "too short is invalid", %{schema: schema} do
      data = "f"
      refute is_valid?(schema, data)
    end

    test "ignores non-strings", %{schema: schema} do
      data = 1
      assert is_valid?(schema, data)
    end

    test "one supplementary Unicode code point is not long enough", %{
      schema: schema
    } do
      data = "💩"
      refute is_valid?(schema, data)
    end
  end
end
