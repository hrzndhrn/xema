defmodule Xema.BoolLogicTest do
  use ExUnit.Case

  doctest Xema.Any

  import Xema

  describe "keyword not:" do
    setup do
      %{schema: xema(:any, not: :integer)}
    end

    test "type", %{schema: schema} do
      assert schema.type.as == :any
    end

    test "validate/2 with a string", %{schema: schema} do
      assert validate(schema, "foo") == :ok
    end
  end
end
