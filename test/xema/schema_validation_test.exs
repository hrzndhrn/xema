defmodule Xema.SchemaValidationTest do
  use ExUnit.Case, async: true

  setup do
    source = {
      :tuple,
      items: [
        [
          any_of: [
            {:ref, "#/definitions/type"},
            {:ref, "#/definitions/types"}
          ]
        ],
        {:ref, "#/definitions/keywords"}
      ],
      min_items: 2,
      max_items: 2,
      definitions: %{
        keywords: {
          :keyword,
          properties: %{
            id: {:string, format: :uri_reference},
            schema: {:string, format: :uri},
            ref: {:string, format: :uri_reference},
            comment: :string,
            title: :string,
            description: :string,
            default: true,
            examples: {:list, items: true},
            multiple_of: {:number, exclusive_minimum: 0},
            maximum: :number,
            exclusive_maximum: [:boolean, :number],
            minimum: :number,
            exclusive_minimum: [:boolean, :number],
            max_length: {:ref, "#/definitions/non_negative_integer"},
            min_length: {:ref, "#/definitions/non_negative_integer"},
            pattern: [
              any_of: [
                {:string, format: :regex},
                {:struct, module: Regex}
              ]
            ],
            additional_items: {:ref, "#/definitions/schema"},
            items: [
              any_of: [
                {:ref, "#/definitions/schema"},
                {:ref, "#/definitions/schemas"}
              ]
            ],
            max_items: {:ref, "#/definitions/non_negative_integer"},
            min_items: {:ref, "#/definitions/non_negative_integer"},
            unique_items: :boolean,
            contains: {:ref, "#/definitions/schema"},
            max_properties: {:ref, "#/definitions/non_negative_integer"},
            min_properties: {:ref, "#/definitions/non_negative_integer"},
            required: [
              any_of: [
                {:list, items: :string},
                {:list, items: :atom}
              ]
            ],
            additional_properties: {:ref, "#/definitions/schema"},
            definitions:
              {:map, additional_properties: {:ref, "#/definitions/schema"}},
            properties:
              {:map, additional_properties: {:ref, "#/definitions/schema"}},
            pattern_properties:
              {:map,
               additional_properties: {:ref, "#/definitions/schema"},
               property_names: [
                 any_of: [
                   {:string, format: :regex},
                   {:struct, module: Regex}
                 ]
               ]},
            dependencies:
              {:map,
               additional_properties: [
                 any_of: [
                   :string,
                   :atom,
                   {:list, items: :string},
                   {:list, items: :atom},
                   {:ref, "#/definitions/schema"}
                 ]
               ]},
            property_names: {:ref, "#/definitions/schema"},
            const: true,
            enum: {:list, items: true, min_items: 1, unique_items: true},
            format: :atom,
            if: {:ref, "#/definitions/schema"},
            then: {:ref, "#/definitions/schema"},
            else: {:ref, "#/definitions/schema"},
            all_of: {:ref, "#/definitions/schemas"},
            any_of: {:ref, "#/definitions/schemas"},
            one_of: {:ref, "#/definitions/schemas"},
            not: {:ref, "#/definitions/schema"}
          }
        },
        non_negative_integer: {:integer, minimum: 0},
        schema: [
          any_of: [
            {:ref, "#"},
            {:ref, "#/definitions/type"},
            {:ref, "#/definitions/types"},
            {:ref, "#/definitions/ref"},
            {:ref, "#/definitions/keywords"},
            {:struct, module: Xema}
          ]
        ],
        schemas: {:list, items: {:ref, "#/definitions/schema"}},
        ref:
          {:tuple,
           min_length: 2,
           max_length: 2,
           items: [
             {:atom, const: :ref},
             {:ref, "#/definitions/keywords/properties/ref"}
           ]},
        type:
          {:atom,
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
             :struct,
             true,
             :tuple
           ]},
        types: {:list, items: {:ref, "#/definitions/type"}}
      }
    }

    schema = Xema.new(source)

    %{schema: schema, source: source}
  end

  test "validate the schema by the schema", %{schema: schema, source: source} do
    assert Xema.validate(schema, source) == :ok
  end

  describe "type" do
    test "with valid value", %{schema: schema} do
      xema = {:integer, []}

      assert Xema.valid?(schema, xema)
    end

    test "with valid list", %{schema: schema} do
      xema = {[:integer, :string], []}

      assert Xema.valid?(schema, xema)
    end

    test "with invalid atom", %{schema: schema} do
      xema = {:foo, []}

      refute Xema.valid?(schema, xema)
    end

    test "with invalid value", %{schema: schema} do
      xema = {"map", []}

      refute Xema.valid?(schema, xema)
    end

    test "with valid keyword is not valid", %{schema: schema} do
      xema = {:minimum, []}

      refute Xema.valid?(schema, xema)
    end

    test "with valid ref is not valid", %{schema: schema} do
      xema = {:ref, "#"}

      refute Xema.valid?(schema, xema)
    end

    test "with invalid atom in list", %{schema: schema} do
      xema = {[:integer, :foo], []}

      refute Xema.valid?(schema, xema)
    end
  end

  describe "keyword" do
    test "minimum with invalid value", %{schema: schema} do
      xema = {:any, [minimum: "2"]}

      refute Xema.valid?(schema, xema)
    end

    test "module", %{schema: schema} do
      xema = {:struct, [module: Rgex]}

      assert Xema.validate(schema, xema) == :ok
    end
  end

  describe "ref" do
    test "in properties", %{schema: schema} do
      xema =
        {:map,
         id: "http://localhost:1234",
         properties: %{
           name: {:ref, "xema_name.exon#/definitions/or_nil"}
         }}

      assert Xema.validate(schema, xema) == :ok
    end
  end

  describe "any_of" do
    test "with struct schema", %{schema: schema} do
      xema =
        {:any,
         any_of: [
           {:string, format: :regex},
           {:struct, module: Rgex}
         ]}

      assert Xema.validate(schema, xema) == :ok
    end
  end
end
