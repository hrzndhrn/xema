defmodule Xema.ConstTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  describe "keyword not:" do
    setup do
      %{schema: Xema.new(const: 42)}
    end

    test "type", %{schema: schema} do
      assert schema.content.type == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 42) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      assert validate(schema, 1) == {:error, %{const: 42, value: 1}}
    end
  end
end
