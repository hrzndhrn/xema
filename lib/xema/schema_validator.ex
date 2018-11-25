defmodule Xema.SchemaValidator do
  @moduledoc false

  alias Xema.Ref
  alias Xema.Schema
  alias Xema.SchemaError

  @schema %Xema{
    schema: %Schema{
      definitions: %{
        keywords: %Schema{
          properties: %{
            min_items: %Schema{
              ref: %Ref{pointer: "#/definitions/non_negative_integer"}
            },
            exclusive_minimum: %Schema{type: [:boolean, :number]},
            if: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
            maximum: %Schema{type: :number},
            ref: %Schema{format: :uri_reference, type: :string},
            examples: %Schema{items: %Schema{type: true}, type: :list},
            any_of: %Schema{
              ref: %Ref{pointer: "#/definitions/schemas"}
            },
            one_of: %Schema{
              ref: %Ref{pointer: "#/definitions/schemas"}
            },
            pattern: %Schema{
              any_of: [
                %Schema{format: :regex, type: :string},
                %Schema{module: Regex, type: :struct}
              ]
            },
            id: %Schema{format: :uri_reference, type: :string},
            title: %Schema{type: :string},
            const: %Schema{type: true},
            unique_items: %Schema{type: :boolean},
            not: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
            max_properties: %Schema{
              ref: %Ref{pointer: "#/definitions/non_negative_integer"}
            },
            additional_items: %Schema{
              ref: %Ref{pointer: "#/definitions/schema"}
            },
            items: %Schema{
              any_of: [
                %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
                %Schema{ref: %Ref{pointer: "#/definitions/schemas"}}
              ]
            },
            then: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
            exclusive_maximum: %Schema{type: [:boolean, :number]},
            max_length: %Schema{
              ref: %Ref{pointer: "#/definitions/non_negative_integer"}
            },
            comment: %Schema{type: :string},
            property_names: %Schema{
              ref: %Ref{pointer: "#/definitions/schema"}
            },
            schema: %Schema{format: :uri, type: :string},
            dependencies: %Schema{
              additional_properties: %Schema{
                any_of: [
                  %Schema{type: :string},
                  %Schema{type: :atom},
                  %Schema{items: %Schema{type: :string}, type: :list},
                  %Schema{items: %Schema{type: :atom}, type: :list},
                  %Schema{ref: %Ref{pointer: "#/definitions/schema"}}
                ]
              },
              type: :map
            },
            description: %Schema{type: :string},
            min_properties: %Schema{
              ref: %Ref{pointer: "#/definitions/non_negative_integer"}
            },
            pattern_properties: %Schema{
              additional_properties: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              property_names: %Schema{
                any_of: [
                  %Schema{format: :regex, type: :string},
                  %Schema{module: Regex, type: :struct}
                ]
              },
              type: :map
            },
            minimum: %Schema{type: :number},
            properties: %Schema{
              additional_properties: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              type: :map
            },
            definitions: %Schema{
              additional_properties: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              type: :map
            },
            enum: %Schema{
              items: %Schema{type: true},
              min_items: 1,
              type: :list,
              unique_items: true
            },
            multiple_of: %Schema{exclusive_minimum: 0, type: :number},
            else: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
            all_of: %Schema{
              ref: %Ref{pointer: "#/definitions/schemas"}
            },
            max_items: %Schema{
              ref: %Ref{pointer: "#/definitions/non_negative_integer"}
            },
            contains: %Schema{
              ref: %Ref{pointer: "#/definitions/schema"}
            },
            additional_properties: %Schema{
              ref: %Ref{pointer: "#/definitions/schema"}
            },
            default: %Schema{type: true},
            required: %Schema{
              any_of: [
                %Schema{items: %Schema{type: :string}, type: :list},
                %Schema{items: %Schema{type: :atom}, type: :list}
              ]
            },
            format: %Schema{
              enum: [
                :date,
                :date_time,
                :email,
                :hostname,
                :ipv4,
                :ipv6,
                :json_pointer,
                :regex,
                :relative_json_pointer,
                :time,
                :uri,
                :uri_fragment,
                :uri_path,
                :uri_query,
                :uri_reference,
                :uri_template,
                :uri_userinfo
              ],
              type: :atom
            }
          },
          type: :keyword
        },
        non_negative_integer: %Schema{minimum: 0, type: :integer},
        ref: %Schema{
          items: [
            %Schema{const: :ref, type: :atom},
            %Schema{
              ref: %Ref{pointer: "#/definitions/keywords/properties/ref"}
            }
          ],
          max_length: 2,
          min_length: 2,
          type: :tuple
        },
        schema: %Schema{
          any_of: [
            %Schema{ref: %Ref{pointer: "#"}},
            %Schema{ref: %Ref{pointer: "#/definitions/type"}},
            %Schema{ref: %Ref{pointer: "#/definitions/types"}},
            %Schema{ref: %Ref{pointer: "#/definitions/ref"}},
            %Schema{ref: %Ref{pointer: "#/definitions/keywords"}},
            %Schema{module: Xema, type: :struct}
          ]
        },
        schemas: %Schema{
          items: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
          type: :list
        },
        type: %Schema{
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
          ],
          type: :atom
        },
        types: %Schema{
          items: %Schema{ref: %Ref{pointer: "#/definitions/type"}},
          type: :list
        }
      },
      items: [
        %Schema{
          any_of: [
            %Schema{ref: %Ref{pointer: "#/definitions/type"}},
            %Schema{ref: %Ref{pointer: "#/definitions/types"}}
          ]
        },
        %Schema{ref: %Ref{pointer: "#/definitions/keywords"}}
      ],
      max_items: 2,
      min_items: 2,
      type: :tuple
    }
  }

  def validate!(val) do
    case Xema.validate(@schema, val) do
      :ok ->
        :ok

      {:error, reason} ->
        raise SchemaError, reason
    end
  end
end
