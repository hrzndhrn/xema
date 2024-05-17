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
        assert error.message == nil
        assert Exception.message(error) == ~s|Expected :integer, got "foo".|
        assert error.reason == %{type: :integer, value: "foo"}
    end
  end

  describe "format_error/1" do
    test "returns a formatted error for an error tuple (:integer)" do
      schema = Xema.new(:integer)

      assert schema |> Validator.validate("foo") |> ValidationError.format_error() ==
               ~s|Expected :integer, got \"foo\".|
    end

    test "returns a formatted error for an error tuple (:list)" do
      schema = Xema.new({:list, items: :integer})
      data = [1, "foo", 2, :bar]

      assert schema |> Validator.validate(data) |> ValidationError.format_error() ==
               """
               Expected :integer, got "foo", at [1].
               Expected :integer, got :bar, at [3].\
               """
    end

    test "returns a formatted error for an an error tuple" do
      schema = Xema.new({:list, items: :integer})
      data = [1, "foo", 2, :bar]

      assert schema |> Xema.validate(data) |> ValidationError.format_error() ==
               """
               Expected :integer, got "foo", at [1].
               Expected :integer, got :bar, at [3].\
               """
    end

    test "returns a formatted error for an an exception" do
      schema = Xema.new({:list, items: :integer})
      data = [1, "foo", 2, :bar]
      {:error, error} = Xema.validate(schema, data)

      assert ValidationError.format_error(error) ==
               """
               Expected :integer, got "foo", at [1].
               Expected :integer, got :bar, at [3].\
               """
    end
  end

  describe "exception/1" do
    test "returns unexpected error for unexpected reason" do
      error = ValidationError.exception(reason: "foo")

      assert error == %Xema.ValidationError{
               message: nil,
               reason: "foo"
             }

      assert Exception.message(error) == "Unexpected error."
    end

    test "returns unexpected error for internal exception" do
      error = ValidationError.exception(reason: %{items: {}})
      assert Exception.message(error) =~ "got Protocol.UndefinedError with message"
    end
  end
end
