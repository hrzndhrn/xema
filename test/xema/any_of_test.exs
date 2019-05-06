defmodule Xema.AnyOfTest do
  use ExUnit.Case, async: true

  import Xema, only: [validate: 2]

  alias Xema.ValidationError

  describe "keyword any_of:" do
    setup do
      %{
        schema:
          Xema.new({
            :any,
            any_of: [nil, {:integer, minimum: 1}]
          })
      }
    end

    test "type", %{schema: schema} do
      assert schema.schema.type == :any
    end

    test "validate/2 with a valid value", %{schema: schema} do
      assert validate(schema, 1) == :ok
      assert validate(schema, nil) == :ok
    end

    test "validate/2 with an invalid value", %{schema: schema} do
      msg = """
      No match of any schema.
        Expected nil, got "foo".
        Expected :integer, got "foo".\
      """

      assert {:error,
              %ValidationError{
                message: ^msg,
                reason: %{
                  any_of: [
                    %{type: nil, value: "foo"},
                    %{type: :integer, value: "foo"}
                  ],
                  value: "foo"
                }
              }} = validate(schema, "foo")
    end
  end

  describe "keyword any_of (shortcut):" do
    setup do
      %{
        schema: Xema.new(any_of: [nil, {:integer, minimum: 1}])
      }
    end

    test "equal long version", %{schema: schema} do
      assert schema ==
               Xema.new({
                 :any,
                 any_of: [nil, {:integer, minimum: 1}]
               })
    end
  end

  describe "keyword any_of with properties and items" do
    setup do
      %{
        schema:
          Xema.new(
            any_of: [
              {:map, properties: %{foo: :integer}},
              {:list, items: :integer}
            ]
          )
      }
    end

    test "validate/2 with invalid string value", %{schema: schema} do
      assert validate(schema, "foo") ==
               {:error,
                %Xema.ValidationError{
                  message: """
                  No match of any schema.
                    Expected :map, got "foo".
                    Expected :list, got "foo".\
                  """,
                  reason: %{
                    any_of: [
                      %{type: :map, value: "foo"},
                      %{type: :list, value: "foo"}
                    ],
                    value: "foo"
                  }
                }}
    end

    test "validate/2 with invalid list value", %{schema: schema} do
      assert validate(schema, ["foo"]) ==
               {:error,
                %ValidationError{
                  message: """
                  No match of any schema.
                    Expected :map, got ["foo"].
                    Expected :integer, got "foo", at [0].\
                  """,
                  reason: %{
                    any_of: [
                      %{type: :map, value: ["foo"]},
                      %{items: [{0, %{type: :integer, value: "foo"}}]}
                    ],
                    value: ["foo"]
                  }
                }}
    end

    test "validate/2 with invalid property value", %{schema: schema} do
      assert validate(schema, %{foo: "foo"}) ==
               {:error,
                %Xema.ValidationError{
                  message: """
                  No match of any schema.
                    Expected :integer, got "foo", at [:foo].
                    Expected :list, got %{foo: "foo"}.\
                  """,
                  reason: %{
                    any_of: [
                      %{properties: %{foo: %{type: :integer, value: "foo"}}},
                      %{type: :list, value: %{foo: "foo"}}
                    ],
                    value: %{foo: "foo"}
                  }
                }}
    end
  end

  describe "keyword any_of with properties and items in a map schema" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             properties: %{
               foo: [
                 any_of: [
                   {:map, properties: %{bar: :integer}},
                   {:list, items: :integer}
                 ]
               ]
             }}
          )
      }
    end

    test "validate/2 with invalid property value", %{schema: schema} do
      assert validate(schema, %{foo: %{bar: "foo"}}) ==
               {:error,
                %Xema.ValidationError{
                  message: """
                  No match of any schema, at [:foo].
                    Expected :integer, got "foo", at [:foo, :bar].
                    Expected :list, got %{bar: "foo"}, at [:foo].\
                  """,
                  reason: %{
                    properties: %{
                      foo: %{
                        any_of: [
                          %{properties: %{bar: %{type: :integer, value: "foo"}}},
                          %{type: :list, value: %{bar: "foo"}}
                        ],
                        value: %{bar: "foo"}
                      }
                    }
                  }
                }}
    end
  end

  describe "nesetd any schema" do
    setup do
      %{
        schema:
          Xema.new(
            any_of: [
              [any_of: [:integer, :float]],
              [any_of: [:list, :map]]
            ]
          )
      }
    end

    test "validate/2 with an valid integer", %{schema: schema} do
      assert validate(schema, 5) == :ok
    end

    test "validate/2 with a valid list", %{schema: schema} do
      assert validate(schema, [5]) == :ok
    end

    test "validate/2 with an invalid string", %{schema: schema} do
      assert validate(schema, "foo") ==
               {:error,
                %Xema.ValidationError{
                  message: """
                  No match of any schema.
                    No match of any schema.
                      Expected :integer, got "foo".
                      Expected :float, got "foo".
                    No match of any schema.
                      Expected :list, got "foo".
                      Expected :map, got "foo".\
                  """,
                  reason: %{
                    any_of: [
                      %{
                        any_of: [
                          %{type: :integer, value: "foo"},
                          %{type: :float, value: "foo"}
                        ],
                        value: "foo"
                      },
                      %{
                        any_of: [
                          %{type: :list, value: "foo"},
                          %{type: :map, value: "foo"}
                        ],
                        value: "foo"
                      }
                    ],
                    value: "foo"
                  }
                }}
    end
  end
end
