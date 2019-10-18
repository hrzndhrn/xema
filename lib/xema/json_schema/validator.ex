defmodule Xema.JsonSchema.Validator do
  @moduledoc false
  # This module contains validators to check schemas against the official
  # JSON Schemas.

  @type json_schema_uri :: String.t()
  @type draft :: String.t()

  @draft04 Xema.new(
             {:map,
              [
                default: %{},
                definitions: %{
                  "positiveInteger" => {:integer, [minimum: 0]},
                  "positiveIntegerDefault0" => [
                    all_of: [
                      {:ref, "#/definitions/positiveInteger"},
                      [default: 0]
                    ]
                  ],
                  "schemaArray" => {:list, [items: {:ref, "#"}, min_items: 1]},
                  "simpleTypes" => [
                    enum: [
                      "array",
                      "boolean",
                      "integer",
                      "null",
                      "number",
                      "object",
                      "string"
                    ]
                  ],
                  "stringArray" => {:list, [items: :string, min_items: 1, unique_items: true]}
                },
                dependencies: %{
                  "exclusiveMaximum" => ["maximum"],
                  "exclusiveMinimum" => ["minimum"]
                },
                description: "Core schema meta-schema",
                id: "http://json-schema.org/draft-04/schema#",
                properties: %{
                  "uniqueItems" => {:boolean, [default: false]},
                  "maximum" => :number,
                  "title" => :string,
                  "multipleOf" => {:number, [exclusive_minimum: true, minimum: 0]},
                  "anyOf" => {:ref, "#/definitions/schemaArray"},
                  "format" => :string,
                  "exclusiveMinimum" => {:boolean, [default: false]},
                  "id" => :string,
                  "minimum" => :number,
                  "definitions" => {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "minItems" => {:ref, "#/definitions/positiveIntegerDefault0"},
                  "additionalProperties" => [
                    any_of: [:boolean, {:ref, "#"}],
                    default: %{}
                  ],
                  "patternProperties" =>
                    {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "type" => [
                    any_of: [
                      ref: "#/definitions/simpleTypes",
                      list: [
                        items: {:ref, "#/definitions/simpleTypes"},
                        min_items: 1,
                        unique_items: true
                      ]
                    ]
                  ],
                  "maxItems" => {:ref, "#/definitions/positiveInteger"},
                  "dependencies" =>
                    {:map,
                     [
                       additional_properties: [
                         any_of: [ref: "#", ref: "#/definitions/stringArray"]
                       ]
                     ]},
                  "$schema" => :string,
                  "maxProperties" => {:ref, "#/definitions/positiveInteger"},
                  "properties" => {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "additionalItems" => [
                    any_of: [:boolean, {:ref, "#"}],
                    default: %{}
                  ],
                  "items" => [
                    any_of: [ref: "#", ref: "#/definitions/schemaArray"],
                    default: %{}
                  ],
                  "not" => {:ref, "#"},
                  "oneOf" => {:ref, "#/definitions/schemaArray"},
                  "default" => :any,
                  "required" => {:ref, "#/definitions/stringArray"},
                  "description" => :string,
                  "allOf" => {:ref, "#/definitions/schemaArray"},
                  "minLength" => {:ref, "#/definitions/positiveIntegerDefault0"},
                  "pattern" => {:string, [format: :regex]},
                  "enum" => {:list, [min_items: 1, unique_items: true]},
                  "exclusiveMaximum" => {:boolean, [default: false]},
                  "maxLength" => {:ref, "#/definitions/positiveInteger"},
                  "minProperties" => {:ref, "#/definitions/positiveIntegerDefault0"}
                },
                schema: "http://json-schema.org/draft-04/schema#"
              ]}
           )

  @draft06 Xema.new(
             {[:map, :boolean],
              [
                default: %{},
                definitions: %{
                  "nonNegativeInteger" => {:integer, [minimum: 0]},
                  "nonNegativeIntegerDefault0" => [
                    all_of: [
                      {:ref, "#/definitions/nonNegativeInteger"},
                      [default: 0]
                    ]
                  ],
                  "schemaArray" => {:list, [items: {:ref, "#"}, min_items: 1]},
                  "simpleTypes" => [
                    enum: [
                      "array",
                      "boolean",
                      "integer",
                      "null",
                      "number",
                      "object",
                      "string"
                    ]
                  ],
                  "stringArray" => {:list, [default: [], items: :string, unique_items: true]}
                },
                id: "http://json-schema.org/draft-06/schema#",
                properties: %{
                  "uniqueItems" => {:boolean, [default: false]},
                  "maximum" => :number,
                  "title" => :string,
                  "propertyNames" => {:ref, "#"},
                  "multipleOf" => {:number, [exclusive_minimum: 0]},
                  "anyOf" => {:ref, "#/definitions/schemaArray"},
                  "format" => :string,
                  "exclusiveMinimum" => :number,
                  "examples" => {:list, [items: :any]},
                  "minimum" => :number,
                  "contains" => {:ref, "#"},
                  "definitions" => {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "minItems" => {:ref, "#/definitions/nonNegativeIntegerDefault0"},
                  "additionalProperties" => {:ref, "#"},
                  "patternProperties" =>
                    {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "type" => [
                    any_of: [
                      ref: "#/definitions/simpleTypes",
                      list: [
                        items: {:ref, "#/definitions/simpleTypes"},
                        min_items: 1,
                        unique_items: true
                      ]
                    ]
                  ],
                  "maxItems" => {:ref, "#/definitions/nonNegativeInteger"},
                  "dependencies" =>
                    {:map,
                     [
                       additional_properties: [
                         any_of: [ref: "#", ref: "#/definitions/stringArray"]
                       ]
                     ]},
                  "const" => :any,
                  "$schema" => {:string, [format: :uri]},
                  "maxProperties" => {:ref, "#/definitions/nonNegativeInteger"},
                  "properties" => {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "additionalItems" => {:ref, "#"},
                  "items" => [
                    any_of: [ref: "#", ref: "#/definitions/schemaArray"],
                    default: %{}
                  ],
                  "not" => {:ref, "#"},
                  "oneOf" => {:ref, "#/definitions/schemaArray"},
                  "$id" => {:string, [format: :uri_reference]},
                  "default" => :any,
                  "required" => {:ref, "#/definitions/stringArray"},
                  "description" => :string,
                  "allOf" => {:ref, "#/definitions/schemaArray"},
                  "minLength" => {:ref, "#/definitions/nonNegativeIntegerDefault0"},
                  "pattern" => {:string, [format: :regex]},
                  "$ref" => {:string, [format: :uri_reference]},
                  "enum" => {:list, [min_items: 1, unique_items: true]},
                  "exclusiveMaximum" => :number,
                  "maxLength" => {:ref, "#/definitions/nonNegativeInteger"},
                  "minProperties" => {:ref, "#/definitions/nonNegativeIntegerDefault0"}
                },
                schema: "http://json-schema.org/draft-06/schema#",
                title: "Core schema meta-schema"
              ]}
           )

  @draft07 Xema.new(
             {[:map, :boolean],
              [
                default: true,
                definitions: %{
                  "nonNegativeInteger" => {:integer, [minimum: 0]},
                  "nonNegativeIntegerDefault0" => [
                    all_of: [
                      {:ref, "#/definitions/nonNegativeInteger"},
                      [default: 0]
                    ]
                  ],
                  "schemaArray" => {:list, [items: {:ref, "#"}, min_items: 1]},
                  "simpleTypes" => [
                    enum: [
                      "array",
                      "boolean",
                      "integer",
                      "null",
                      "number",
                      "object",
                      "string"
                    ]
                  ],
                  "stringArray" => {:list, [default: [], items: :string, unique_items: true]}
                },
                id: "http://json-schema.org/draft-07/schema#",
                properties: %{
                  "uniqueItems" => {:boolean, [default: false]},
                  "maximum" => :number,
                  "title" => :string,
                  "propertyNames" => {:ref, "#"},
                  "multipleOf" => {:number, [exclusive_minimum: 0]},
                  "anyOf" => {:ref, "#/definitions/schemaArray"},
                  "format" => :string,
                  "exclusiveMinimum" => :number,
                  "examples" => {:list, [items: true]},
                  "minimum" => :number,
                  "contains" => {:ref, "#"},
                  "definitions" => {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "minItems" => {:ref, "#/definitions/nonNegativeIntegerDefault0"},
                  "additionalProperties" => {:ref, "#"},
                  "patternProperties" =>
                    {:map,
                     [
                       additional_properties: {:ref, "#"},
                       default: %{},
                       property_names: [format: :regex]
                     ]},
                  "contentMediaType" => :string,
                  "type" => [
                    any_of: [
                      ref: "#/definitions/simpleTypes",
                      list: [
                        items: {:ref, "#/definitions/simpleTypes"},
                        min_items: 1,
                        unique_items: true
                      ]
                    ]
                  ],
                  "maxItems" => {:ref, "#/definitions/nonNegativeInteger"},
                  "readOnly" => {:boolean, [default: false]},
                  "else" => {:ref, "#"},
                  "dependencies" =>
                    {:map,
                     [
                       additional_properties: [
                         any_of: [ref: "#", ref: "#/definitions/stringArray"]
                       ]
                     ]},
                  "$comment" => :string,
                  "const" => true,
                  "$schema" => {:string, [format: :uri]},
                  "maxProperties" => {:ref, "#/definitions/nonNegativeInteger"},
                  "properties" => {:map, [additional_properties: {:ref, "#"}, default: %{}]},
                  "additionalItems" => {:ref, "#"},
                  "items" => [
                    any_of: [ref: "#", ref: "#/definitions/schemaArray"],
                    default: true
                  ],
                  "not" => {:ref, "#"},
                  "oneOf" => {:ref, "#/definitions/schemaArray"},
                  "$id" => {:string, [format: :uri_reference]},
                  "if" => {:ref, "#"},
                  "then" => {:ref, "#"},
                  "default" => true,
                  "required" => {:ref, "#/definitions/stringArray"},
                  "description" => :string,
                  "allOf" => {:ref, "#/definitions/schemaArray"},
                  "minLength" => {:ref, "#/definitions/nonNegativeIntegerDefault0"},
                  "pattern" => {:string, [format: :regex]},
                  "$ref" => {:string, [format: :uri_reference]},
                  "enum" => {:list, [items: true, min_items: 1, unique_items: true]},
                  "contentEncoding" => :string,
                  "exclusiveMaximum" => :number,
                  "maxLength" => {:ref, "#/definitions/nonNegativeInteger"},
                  "minProperties" => {:ref, "#/definitions/nonNegativeIntegerDefault0"}
                },
                schema: "http://json-schema.org/draft-07/schema#",
                title: "Core schema meta-schema"
              ]}
           )

  @doc """
  This function validates schemas against:
  + draft4: http://json-schema.org/draft-04/schema#
  + draft6: http://json-schema.org/draft-06/schema#
  + draft7: http://json-schema.org/draft-07/schema#

  The function expected the URI as string or the name of the draft.

  ## Examples

      iex> Xema.JsonSchema.Validator.validate("draft7", %{"type" => "integer"})
      :ok

      iex> uri = "http://json-schema.org/draft-07/schema#"
      iex> Xema.JsonSchema.Validator.validate(uri, %{"type" => "integer"})
      :ok
      iex> Xema.JsonSchema.Validator.validate(uri, %{"minimum" => "55"})
      {:error, %Xema.ValidationError{
        reason: %{properties: %{"minimum" => %{type: :number, value: "55"}}}
      }}

      iex> Xema.JsonSchema.Validator.validate("foo", %{"type" => "integer"})
      {:error, :unknown}
  """
  @spec validate(json_schema_uri() | draft(), any) ::
          Xema.Validator.result() | {:error, :unknown}
  def validate("http://json-schema.org/draft-04/schema#", value),
    do: Xema.validate(@draft04, value)

  def validate("draft4", value),
    do: Xema.validate(@draft04, value)

  def validate("http://json-schema.org/draft-06/schema#", value),
    do: Xema.validate(@draft06, value)

  def validate("draft6", value),
    do: Xema.validate(@draft06, value)

  def validate("http://json-schema.org/draft-07/schema#", value),
    do: Xema.validate(@draft07, value)

  def validate("draft7", value),
    do: Xema.validate(@draft07, value)

  def validate(_, _), do: {:error, :unknown}
end
