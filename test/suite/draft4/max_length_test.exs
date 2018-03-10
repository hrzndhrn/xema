defmodule Draft4.MaxLengthTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "maxLength validation" do
    setup do
      %{schema: Xema.new(:max_length, 2)}
    end

    @tag :draft4
    @tag :max_length
    test "shorter is valid", %{schema: schema} do
      data = "f"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_length
    test "exact length is valid", %{schema: schema} do
      data = "fo"
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_length
    test "too long is invalid", %{schema: schema} do
      data = "foo"
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_length
    test "ignores non-strings", %{schema: schema} do
      data = 100
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :max_length
    test "two supplementary Unicode code points is long enough", %{
      schema: schema
    } do
      data = "💩💩"
      assert is_valid?(schema, data)
    end
  end
end
