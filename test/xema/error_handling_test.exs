defmodule Xema.ErrorHandlingTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  test "wrong arguments" do
    expected =
      "Can't build schema! " <>
        "reason: %{items: [{1, %{type: :keyword, value: %{minimum: 0}}}]}"

    assert_raise SchemaError, expected, fn ->
      Xema.new({:integer, %{minimum: 0}})
    end
  end

  test "wrong arguments in tuple" do
    expected = ~r/Can't build schema!.*/

    # TODO: Invalid schema #/1/properties/pos

    assert_raise SchemaError, expected, fn ->
      Xema.new({
        :map,
        properties: %{
          pos: {:string, %{min_length: 10}}
        }
      })
    end
  end
end
