defmodule Xema.ValidationErrorTest do
  use ExUnit.Case, async: true

  doctest Xema.ValidationError

  alias Xema.ValidationError
  alias Xema.Validator

  describe "Xema.validate!/2" do
    setup do
      %{schema: Xema.new(:integer)}
    end

    test "returns a ValidationError for invalid data", %{schema: schema} do
      Xema.validate!(schema, "foo")
    rescue
      error ->
        assert %ValidationError{} = error
        assert error.message == ~s|Expected :integer, got "foo".|
        assert error.reason == %{type: :integer, value: "foo"}
    end
  end

  describe "format_error/1" do
    setup do
      %{schema: Xema.new(:integer)}
    end

    test "returns a formated error for an error tuple", %{schema: schema} do
      assert schema |> Validator.validate("foo") |> ValidationError.format_error() ==
               ~s|Expected :integer, got \"foo\".|
    end
  end

  describe "exception/1" do
    test "returns unexpected error for unexpected reason" do
      assert ValidationError.exception("foo") == %Xema.ValidationError{
               message: "Unexpected error.",
               reason: "foo"
             }
    end

    test "returns unexpected error for internal exception" do
      assert ValidationError.exception(%{items: {}}) == %Xema.ValidationError{
               message: "Unexpected error.",
               reason: %Protocol.UndefinedError{description: "", protocol: Enumerable, value: {}}
             }
    end
  end
end
