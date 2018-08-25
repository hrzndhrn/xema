defmodule Xema.ErrorHandlingTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  test "wrong arguments" do
    expected = "Wrong argument for :integer. Argument: %{minimum: 0}"

    assert_raise SchemaError, expected, fn ->
      Xema.new(:integer, %{minimum: 0})
    end
  end

  test "wrong arguments in tuple" do
    expected = "Wrong argument for :string. Argument: %{min_length: 10}"

    assert_raise SchemaError, expected, fn ->
      Xema.new(
        :map,
        properties: %{
          pos: {:string, %{min_length: 10}}
        }
      )
    end
  end
end
