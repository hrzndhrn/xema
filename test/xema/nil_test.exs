defmodule Xema.NilTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  describe "'nil' schema" do
    setup do
      %{schema: Xema.new(nil)}
    end

    test "type", %{schema: schema} do
      assert schema.content.as == nil
    end

    test "validate/2 with nil value", %{schema: schema} do
      assert validate(schema, nil) == :ok
    end

    test "validate/2 with non-nil value", %{schema: schema} do
      expected = {:error, %{type: nil, value: 1}}

      assert validate(schema, 1) == expected
    end
  end
end
