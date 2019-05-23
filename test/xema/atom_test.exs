defmodule Xema.AtomTest do
  use ExUnit.Case, async: true

  import Xema, only: [valid?: 2, validate: 2]

  alias Xema.ValidationError

  describe "atom schema" do
    setup do
      %{schema: Xema.new(:atom)}
    end

    test "validate/2 with an atom", %{schema: schema} do
      assert validate(schema, :foo) == :ok
    end

    test "validate/2 with a float", %{schema: schema} do
      assert {
               :error,
               %ValidationError{
                 reason: %{
                   type: :atom,
                   value: 2.3
                 }
               } = error
             } = validate(schema, 2.3)

      assert Exception.message(error) == "Expected :atom, got 2.3."
    end

    test "validate/2 with a string", %{schema: schema} do
      assert {:error,
              %ValidationError{
                reason: %{
                  type: :atom,
                  value: "foo"
                }
              } = error} = validate(schema, "foo")

      assert Exception.message(error) == ~s|Expected :atom, got "foo".|
    end

    test "valid?/2 with a valid value", %{schema: schema} do
      assert valid?(schema, :bar)
    end

    test "valid?/2 with an invalid value", %{schema: schema} do
      refute(valid?(schema, [1]))
    end
  end
end
