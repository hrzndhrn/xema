defmodule Xema.ErrorHandlingTest do
  use ExUnit.Case, async: true

  alias Xema.SchemaError

  test "wrong arguments" do
    expected =
      """
      Can't build schema! Reason:
      %{items: [{1, %{type: :keyword, value: %{minimum: 0}}}]}
      """
      |> String.trim_trailing()

    assert_raise SchemaError, expected, fn ->
      Xema.new({:integer, %{minimum: 0}})
    end
  end

  @tag :only
  test "test" do
    Xema.new({
      :map,
      properties: %{
        pos: {:string, %{min_length: 10}}
      }
    })
  rescue
    error ->
      assert %SchemaError{} = error
      assert Regex.match?(~r/Can't build schema!.*/, error.message)

      assert error.reason == %{
               items: [
                 {1,
                  %{
                    properties: %{
                      properties: %{
                        pos: %{
                          any_of: [
                            %{
                              items: [
                                {1, %{type: :keyword, value: %{min_length: 10}}}
                              ]
                            },
                            %{type: :atom, value: {:string, %{min_length: 10}}},
                            %{type: :list, value: {:string, %{min_length: 10}}},
                            %{
                              items: [
                                {0, %{const: :ref, value: :string}},
                                {1, %{type: :string, value: %{min_length: 10}}}
                              ]
                            },
                            %{
                              type: :keyword,
                              value: {:string, %{min_length: 10}}
                            },
                            %{
                              type: :struct,
                              value: {:string, %{min_length: 10}}
                            }
                          ],
                          value: {:string, %{min_length: 10}}
                        }
                      }
                    }
                  }}
               ]
             }
  end
end
