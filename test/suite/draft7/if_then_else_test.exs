defmodule Draft7.IfThenElseTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2]

  describe "ignore if without then or else" do
    setup do
      %{schema: Xema.new(:if, {:const, 0})}
    end

    test "valid when valid against lone if", %{schema: schema} do
      data = 0
      assert valid?(schema, data)
    end

    test "valid when invalid against lone if", %{schema: schema} do
      data = "hello"
      assert valid?(schema, data)
    end
  end

  describe "ignore then without if" do
    setup do
      %{schema: Xema.new(:then, {:const, 0})}
    end

    test "valid when valid against lone then", %{schema: schema} do
      data = 0
      assert valid?(schema, data)
    end

    test "valid when invalid against lone then", %{schema: schema} do
      data = "hello"
      assert valid?(schema, data)
    end
  end

  describe "ignore else without if" do
    setup do
      %{schema: Xema.new(:else, {:const, 0})}
    end

    test "valid when valid against lone else", %{schema: schema} do
      data = 0
      assert valid?(schema, data)
    end

    test "valid when invalid against lone else", %{schema: schema} do
      data = "hello"
      assert valid?(schema, data)
    end
  end

  describe "if and then without else" do
    setup do
      %{
        schema:
          Xema.new(:any, if: {:exclusive_maximum, 0}, then: {:minimum, -10})
      }
    end

    test "valid through then", %{schema: schema} do
      data = -1
      assert valid?(schema, data)
    end

    test "invalid through then", %{schema: schema} do
      data = -100
      refute valid?(schema, data)
    end

    test "valid when if test fails", %{schema: schema} do
      data = 3
      assert valid?(schema, data)
    end
  end

  describe "if and else without then" do
    setup do
      %{
        schema:
          Xema.new(:any, else: {:multiple_of, 2}, if: {:exclusive_maximum, 0})
      }
    end

    test "valid when if test passes", %{schema: schema} do
      data = -1
      assert valid?(schema, data)
    end

    test "valid through else", %{schema: schema} do
      data = 4
      assert valid?(schema, data)
    end

    test "invalid through else", %{schema: schema} do
      data = 3
      refute valid?(schema, data)
    end
  end

  describe "validate against correct branch, then vs else" do
    setup do
      %{
        schema:
          Xema.new(:any,
            else: {:multiple_of, 2},
            if: {:exclusive_maximum, 0},
            then: {:minimum, -10}
          )
      }
    end

    test "valid through then", %{schema: schema} do
      data = -1
      assert valid?(schema, data)
    end

    test "invalid through then", %{schema: schema} do
      data = -100
      refute valid?(schema, data)
    end

    test "valid through else", %{schema: schema} do
      data = 4
      assert valid?(schema, data)
    end

    test "invalid through else", %{schema: schema} do
      data = 3
      refute valid?(schema, data)
    end
  end

  describe "non-interference across combined schemas" do
    setup do
      %{
        schema:
          Xema.new(:all_of,
            if: {:exclusive_maximum, 0},
            then: {:minimum, -10},
            else: {:multiple_of, 2}
          )
      }
    end

    test "valid, but woud have been invalid through then", %{schema: schema} do
      data = -100
      assert valid?(schema, data)
    end

    test "valid, but would have been invalid through else", %{schema: schema} do
      data = 3
      assert valid?(schema, data)
    end
  end
end
