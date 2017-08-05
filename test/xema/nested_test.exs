defmodule Xema.NestedTest do

  use ExUnit.Case, async: true

  import Xema

  describe "list of objects in one schema" do
    setup do
      %{schema:
        xema(
          :map,
          properties: %{
            id: {:number, minimum: 1},
            items: {:list,
              items: {:map,
                properties: %{
                  num: {:number, minimum: 0},
                  desc: :string
                }
              }
            }
          }
        )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      data = %{
        id: 5,
        items: [
          %{num: 1, desc: "foo"},
          %{num: 2, desc: "bar"}
        ]
      }

      assert validate(schema, data) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      data = %{
        id: 5,
        items: [
          %{num: 1, desc: "foo"},
          %{num: -2, desc: "bar"}
        ]
      }

      error = {
        :error,
        %{
          reason: :invalid_property,
          property: :items,
          error: %{
            reason: :invalid_item,
            at: 1,
            error: %{
              reason: :invalid_property,
              property: :num,
              error: %{
                reason: :too_small,
                minimum: 0,
              },
            },
          },
        }
      }

      assert validate(schema, data) == error
    end
  end

  describe "list of objects in two schemas" do
    setup do
      item = xema :map,
        properties: %{
          num: {:number, minimum: 0},
          desc: :string
        }

      %{schema:
        xema(
          :map,
          properties: %{
            id: {:number, minimum: 1},
            items: {:list, items: item}
          }
        )
      }
    end

    test "validate/2 with valid data", %{schema: schema} do
      data = %{
        id: 5,
        items: [
          %{num: 1, desc: "foo"},
          %{num: 2, desc: "bar"}
        ]
      }

      assert validate(schema, data) == :ok
    end

    test "validate/2 with invalid data", %{schema: schema} do
      data = %{
        id: 5,
        items: [
          %{num: 1, desc: "foo"},
          %{num: -2, desc: "bar"}
        ]
      }

      error = {
        :error,
        %{
          reason: :invalid_property,
          property: :items,
          error: %{
            reason: :invalid_item,
            at: 1,
            error: %{
              reason: :invalid_property,
              property: :num,
              error: %{
                reason: :too_small,
                minimum: 0,
              },
            },
          },
        }
      }

      assert validate(schema, data) == error
    end
  end
end
