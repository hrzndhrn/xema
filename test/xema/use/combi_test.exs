defmodule Xema.Use.CombiTest do
  use ExUnit.Case, async: true

  describe "any_of schema" do
    defmodule MySchema.Any do
      use Xema

      xema do
        any_of [
          list(items: integer(minimum: 1, maximum: 66)),
          list(items: integer(minimum: 33, maximum: 100))
        ]
      end
    end

    test "valild?/1 returns true for a valied list" do
      assert MySchema.Any.valid?([20, 30])
      assert MySchema.Any.valid?([40, 50])
      assert MySchema.Any.valid?([60, 70])
    end

    test "valid?/1 returns false for an invalid list" do
      refute MySchema.Any.valid?([10, 90])
    end
  end

  describe "all_of schema" do
    defmodule MySchema.All do
      use Xema

      xema do
        all_of [
          list(items: integer(minimum: 1, maximum: 66)),
          list(items: integer(minimum: 33, maximum: 100))
        ]
      end
    end

    test "valild?/1 returns true for a valied list" do
      assert MySchema.All.valid?([40, 50])
    end

    test "valid?/1 returns false for an invalid list" do
      refute MySchema.All.valid?([10, 90])
      refute MySchema.All.valid?([20, 30])
      refute MySchema.All.valid?([60, 70])
    end
  end

  describe "one_of schema" do
    defmodule MySchema.One do
      use Xema

      xema do
        one_of [
          list(items: integer(minimum: 1, maximum: 66)),
          list(items: integer(minimum: 33, maximum: 100))
        ]
      end
    end

    test "valild?/1 returns true for a valied list" do
      assert MySchema.One.valid?([20, 30])
      assert MySchema.One.valid?([60, 70])
    end

    test "valid?/1 returns false for an invalid list" do
      refute MySchema.One.valid?([10, 90])
      refute MySchema.One.valid?([40, 50])
    end
  end
end
