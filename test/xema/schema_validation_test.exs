defmodule Xema.SchemaValidationTest do
  use ExUnit.Case, async: true

  setup do
    type =
      Xema.new(
        :atom,
        enum: [
          :any,
          :atom,
          :boolean,
          false,
          :float,
          :integer,
          :keyword,
          :list,
          :map,
          nil,
          :number,
          :string,
          true,
          :tuple
        ]
      )

    %{
      schema:
        Xema.new(
          :tuple,
          items: [
            {:ref, "#/definitions/type"},
            {:ref, "#/definitions/keywords"}
          ],
          min_items: 2,
          max_items: 2,
          definitions: %{
            keywords: {
              :keyword,
              properties: %{
                minimum: :integer
              }
            },
            type: [
              any_of: [
                type,
                {:list, items: {:ref, "#/definitions/type"}}
              ]
            ]
          }
        )
    }
  end

  test "valid type", %{schema: schema} do
    # IO.inspect(schema)
    xema = {:integer, []}

    assert Xema.validate(schema, xema) == :ok
  end

  test "valid type list", %{schema: schema} do
    xema = {[:integer, :string], []}

    assert Xema.validate(schema, xema) == :ok
  end

  test "invalid type", %{schema: schema} do
    xema = {:foo, []}

    assert Xema.validate(schema, xema) ==
             {:error,
              [
                {0,
                 %{
                   value: :foo,
                   enum: [
                     :any,
                     :atom,
                     :boolean,
                     false,
                     :float,
                     :integer,
                     :keyword,
                     :list,
                     :map,
                     nil,
                     :number,
                     :string,
                     true,
                     :tuple
                   ]
                 }}
              ]}
  end

  @tag :only
  test "invalid type in list", %{schema: schema} do
    xema = {[:integer, :foo], []}

    assert Xema.validate(schema, xema) == :error
  end

  test "keyword minimum with valid value", %{schema: schema} do
    xema = {:any, [minimum: 2]}

    assert Xema.validate(schema, xema) == :ok
  end

  test "keyword minimum with invalid value", %{schema: schema} do
    xema = {:any, [minimum: "2"]}

    assert Xema.validate(schema, xema) ==
             {:error,
              [{1, %{properties: %{minimum: %{type: :integer, value: "2"}}}}]}
  end
end
