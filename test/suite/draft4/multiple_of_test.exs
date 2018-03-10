defmodule Draft4.MultipleOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2]

  describe "by int" do
    setup do
      %{schema: Xema.new(:multiple_of, 2)}
    end

    @tag :draft4
    @tag :multiple_of
    test "int by int", %{schema: schema} do
      data = 10
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :multiple_of
    test "int by int fail", %{schema: schema} do
      data = 7
      refute is_valid?(schema, data)
    end

    @tag :draft4
    @tag :multiple_of
    test "ignores non-numbers", %{schema: schema} do
      data = "foo"
      assert is_valid?(schema, data)
    end
  end

  describe "by number" do
    setup do
      %{schema: Xema.new(:multiple_of, 1.5)}
    end

    @tag :draft4
    @tag :multiple_of
    test "zero is multiple of anything", %{schema: schema} do
      data = 0
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :multiple_of
    test "4.5 is multiple of 1.5", %{schema: schema} do
      data = 4.5
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :multiple_of
    test "35 is not multiple of 1.5", %{schema: schema} do
      data = 35
      refute is_valid?(schema, data)
    end
  end

  describe "by small number" do
    setup do
      %{schema: Xema.new(:multiple_of, 0.0001)}
    end

    @tag :draft4
    @tag :multiple_of
    test "0.0075 is multiple of 0.0001", %{schema: schema} do
      data = 0.0075
      assert is_valid?(schema, data)
    end

    @tag :draft4
    @tag :multiple_of
    test "0.00751 is not multiple of 0.0001", %{schema: schema} do
      data = 0.00751
      refute is_valid?(schema, data)
    end
  end
end
