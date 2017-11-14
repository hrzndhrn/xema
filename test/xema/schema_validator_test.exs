defmodule Xema.SchemaValidatorTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  import Xema

  test "keyword minimum with wrong value" do
    expected = ~s(Expected an integer for minimum, got "5")

    assert_raise SchemaError, expected, fn ->
      xema(:integer, minimum: "5")
    end

    assert_raise SchemaError, expected, fn ->
      xema(:map, properties: %{foo: {:integer, minimum: "5"}})
    end
  end
end
