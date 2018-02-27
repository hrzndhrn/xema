defmodule Suite.Draft4.MinLengthTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "min_length validation" do
    setup do
      %{schema: Xema.new(:min_length, 2)}
    end

    @tag :draft4
    @tag :min_length
    test "longer is valid", %{schema: schema} do
      data = "foo"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :min_length
    test "exact length is valid", %{schema: schema} do
      data = "fo"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :min_length
    test "too short is invalid", %{schema: schema} do
      data = "f"
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :min_length
    test "ignores non-strings", %{schema: schema} do
      data = 1
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :min_length
    test "one supplementary Unicode code point is not long enough", %{
      schema: schema
    } do
      data = "💩"
      refute is_valid?(schema, data)
    end
  end
end
