defmodule Xema.NilTest do

  use ExUnit.Case, async: true

  import Xema
  import Xema.TestSupport

  describe "'nil' schema" do
    setup do
      %{schema: xema(:nil)}
    end

    test "type", %{schema: schema} do
      assert type(schema, :nil)
      assert as(schema, :nil)
    end

    test "validate/2 with nil value", %{schema: schema},
      do: assert validate(schema, nil) == :ok

    test "validate/2 with non-nil value", %{schema: schema} do
      assert validate(schema, 1) == {:error, %{reason: :wrong_type, type: nil}}
    end

    test "is_valid?/2 with nil value", %{schema: schema},
      do: assert is_valid?(schema, nil)

    test "is_valid?/2 with non-nil value", %{schema: schema},
      do: refute is_valid?(schema, 1)
  end
end
