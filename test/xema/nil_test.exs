defmodule Xema.NilTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "'nil' schema" do
    setup do
      %{schema: Xema.new(nil)}
    end

    test "check schema", %{schema: schema} do
      assert schema == %Xema{refs: %{}, schema: %Xema.Schema{type: nil}}
    end

    test "validate/2 with nil value", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "validate/2 with non-nil value", %{schema: schema} do
      assert {
               :error,
               %ValidationError{message: "Expected nil, got 1.", reason: %{type: nil, value: 1}}
             } = validate(schema, 1)
    end
  end
end
