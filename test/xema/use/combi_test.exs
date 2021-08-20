defmodule Xema.Use.CombiTest do
  use ExUnit.Case, async: true

  alias Xema.Builder

  describe "any_of schema:" do
    defmodule MySchema.Any do
      use Xema

      xema do
        any_of [
          list(items: integer(minimum: 1, maximum: 66)),
          list(items: integer(minimum: 33, maximum: 100))
        ]
      end
    end

    test "valild?/1 returns true for a valid list" do
      assert MySchema.Any.valid?([20, 30])
      assert MySchema.Any.valid?([40, 50])
      assert MySchema.Any.valid?([60, 70])
    end

    test "valid?/1 returns false for an invalid list" do
      refute MySchema.Any.valid?([10, 90])
    end
  end

  describe "any_of integer schema:" do
    setup do
      schema =
        :integer
        |> Builder.any_of([[minimum: 10], [maximum: 5]])
        |> Xema.new()

      %{schema: schema}
    end

    test "valid?/1 returns true", %{schema: schema} do
      assert Xema.valid?(schema, 1)
      assert Xema.valid?(schema, 11)
    end

    test "valid?/1 returns false", %{schema: schema} do
      refute Xema.valid?(schema, 7)
    end
  end

  describe "all_of schema:" do
    defmodule MySchema.All do
      use Xema

      xema do
        all_of [
          list(items: integer(minimum: 1, maximum: 66)),
          list(items: integer(minimum: 33, maximum: 100))
        ]
      end
    end

    test "valild?/1 returns true for a valid list" do
      assert MySchema.All.valid?([40, 50])
    end

    test "valid?/1 returns false for an invalid list" do
      refute MySchema.All.valid?([10, 90])
      refute MySchema.All.valid?([20, 30])
      refute MySchema.All.valid?([60, 70])
    end
  end

  describe "all_of integer schema:" do
    setup do
      schema =
        :integer
        |> Builder.all_of([[multiple_of: 2], [multiple_of: 3]])
        |> Xema.new()

      %{schema: schema}
    end

    test "valid?/1 returns true", %{schema: schema} do
      assert Xema.valid?(schema, 6)
      assert Xema.valid?(schema, 12)
    end

    test "valid?/1 returns false", %{schema: schema} do
      refute Xema.valid?(schema, 8)
      refute Xema.valid?(schema, 9)
    end
  end

  describe "one_of schema:" do
    defmodule MySchema.One do
      use Xema

      xema do
        one_of [
          list(items: integer(minimum: 1, maximum: 66)),
          list(items: integer(minimum: 33, maximum: 100))
        ]
      end
    end

    test "valild?/1 returns true for a valid list" do
      assert MySchema.One.valid?([20, 30])
      assert MySchema.One.valid?([60, 70])
    end

    test "valid?/1 returns false for an invalid list" do
      refute MySchema.One.valid?([10, 90])
      refute MySchema.One.valid?([40, 50])
    end
  end

  describe "one_of integer schema:" do
    setup do
      schema =
        :integer
        |> Builder.one_of([[multiple_of: 2], [multiple_of: 3]])
        |> Xema.new()

      %{schema: schema}
    end

    test "valid?/1 returns true", %{schema: schema} do
      assert Xema.valid?(schema, 8)
      assert Xema.valid?(schema, 9)
    end

    test "valid?/1 returns false", %{schema: schema} do
      refute Xema.valid?(schema, 6)
      refute Xema.valid?(schema, 12)
    end
  end
end
