defmodule Xema.NestedTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "list of objects in one schema" do
    setup do
      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              id: {:number, minimum: 1},
              items: {
                :list,
                items: {
                  :map,
                  properties: %{
                    num: {:number, minimum: 0},
                    desc: :string
                  }
                }
              }
            }
          })
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

      assert {:error,
              %ValidationError{
                message: "Value -2 is less than minimum value of 0, at [:items, 1, :num].",
                reason: %{
                  properties: %{
                    items: %{
                      items: [{1, %{properties: %{num: %{minimum: 0, value: -2}}}}]
                    }
                  }
                }
              }} = validate(schema, data)
    end
  end

  describe "list of objects in two schemas" do
    setup do
      item =
        Xema.new({
          :map,
          properties: %{
            num: {:number, minimum: 0},
            desc: :string
          }
        })

      %{
        schema:
          Xema.new({
            :map,
            properties: %{
              id: {:number, minimum: 1},
              items: {:list, items: item}
            }
          })
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
        id: 6,
        items: [
          %{num: 1, desc: "foo"},
          %{num: -2, desc: "bar"}
        ]
      }

      assert {:error,
              %ValidationError{
                message: "Value -2 is less than minimum value of 0, at [:items, 1, :num].",
                reason: %{
                  properties: %{
                    items: %{
                      items: [{1, %{properties: %{num: %{minimum: 0, value: -2}}}}]
                    }
                  }
                }
              }} = validate(schema, data)
    end
  end
end
