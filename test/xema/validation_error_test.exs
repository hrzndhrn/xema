defmodule Xema.ValidationErrorTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate!: 2]

  alias Xema.ValidationError

  describe "integer schema" do
    setup do
      %{schema: Xema.new(:integer)}
    end

    test "validate!/2 with a string", %{schema: schema} do
      validate!(schema, "foo")
    rescue
      error ->
        assert %ValidationError{} = error
        assert error.message == ~s|Expected :integer, got "foo".|
        assert error.reason == %{type: :integer, value: "foo"}
    end
  end
end
