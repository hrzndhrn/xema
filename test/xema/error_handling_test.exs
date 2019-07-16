defmodule Xema.ErrorHandlingTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  test "wrong arguments" do
    expected = """
    Can't build schema:
    Expected :keyword, got %{minimum: 0}, at [1].\
    """

    assert_raise SchemaError, expected, fn ->
      Xema.new({:integer, %{minimum: 0}})
    end
  end

  test "test" do
    Xema.new({
      :map,
      properties: %{
        pos: {:string, %{min_length: 10}}
      }
    })
  rescue
    error ->
      message = """
      Can't build schema:
      No match of any schema, at [1, :properties, :pos].
        Expected :keyword, got %{min_length: 10}, at [1, :properties, :pos, 1].
        Expected :atom, got {:string, %{min_length: 10}}, at [1, :properties, :pos].
        Expected :list, got {:string, %{min_length: 10}}, at [1, :properties, :pos].
        Expected :ref, got :string, at [1, :properties, :pos, 0].
        Expected :string, got %{min_length: 10}, at [1, :properties, :pos, 1].
        Expected :keyword, got {:string, %{min_length: 10}}, at [1, :properties, :pos].
        Expected :struct, got {:string, %{min_length: 10}}, at [1, :properties, :pos].
        Expected :atom, got {:string, %{min_length: 10}}, at [1, :properties, :pos].\
      """

      reason = %{
        items: [
          {1,
           %{
             properties: %{
               properties: %{
                 properties: %{
                   pos: %{
                     any_of: [
                       %{items: [{1, %{type: :keyword, value: %{min_length: 10}}}]},
                       %{type: :atom, value: {:string, %{min_length: 10}}},
                       %{type: :list, value: {:string, %{min_length: 10}}},
                       %{
                         items: [
                           {0, %{const: :ref, value: :string}},
                           {1, %{type: :string, value: %{min_length: 10}}}
                         ]
                       },
                       %{type: :keyword, value: {:string, %{min_length: 10}}},
                       %{type: :struct, value: {:string, %{min_length: 10}}},
                       %{type: :atom, value: {:string, %{min_length: 10}}}
                     ],
                     value: {:string, %{min_length: 10}}
                   }
                 }
               }
             }
           }}
        ]
      }

      assert %SchemaError{} = error
      assert error.reason == reason
      assert error.message == message
  end
end
