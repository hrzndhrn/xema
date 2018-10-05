defmodule Xema.AtomTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  describe "atom schema" do
    setup do
      %{schema: Xema.new(:atom)}
    end

    test "validate/2 with an atom", %{schema: schema} do
      assert validate(schema, :foo) == :ok
    end

    test "validate/2 with a float", %{schema: schema} do
      assert validate(schema, 2.3) == {:error, %{type: :atom, value: 2.3}}
    end

    test "validate/2 with a string", %{schema: schema} do
      assert validate(schema, "foo") == {:error, %{type: :atom, value: "foo"}}
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, :bar)
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute(valid?(schema, [1]))
    end
  end
end
