defmodule Xema.SchemaValidator do
  @moduledoc false

  alias Xema.SchemaError

  @schema %Xema{
    content: %Xema.Schema{
      definitions: %{
        keywords: %Xema.Schema{
          properties: %{
            min_items: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/non_negative_integer"}
            },
            exclusive_minimum: %Xema.Schema{type: [:boolean, :number]},
            if: %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schema"}},
            maximum: %Xema.Schema{type: :number},
            ref: %Xema.Schema{format: :uri_reference, type: :string},
            examples: %Xema.Schema{items: %Xema.Schema{type: true}, type: :list},
            any_of: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/schemas"}
            },
            one_of: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/schemas"}
            },
            pattern: %Xema.Schema{
              any_of: [
                %Xema.Schema{format: :regex, type: :string},
                %Xema.Schema{module: Regex, type: :struct}
              ]
            },
            id: %Xema.Schema{format: :uri_reference, type: :string},
            title: %Xema.Schema{type: :string},
            const: %Xema.Schema{type: true},
            unique_items: %Xema.Schema{type: :boolean},
            not: %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schema"}},
            max_properties: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/non_negative_integer"}
            },
            additional_items: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/schema"}
            },
            items: %Xema.Schema{
              any_of: [
                %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schema"}},
                %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schemas"}}
              ]
            },
            then: %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schema"}},
            exclusive_maximum: %Xema.Schema{type: [:boolean, :number]},
            max_length: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/non_negative_integer"}
            },
            comment: %Xema.Schema{type: :string},
            property_names: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/schema"}
            },
            schema: %Xema.Schema{format: :uri, type: :string},
            dependencies: %Xema.Schema{
              additional_properties: %Xema.Schema{
                any_of: [
                  %Xema.Schema{type: :string},
                  %Xema.Schema{type: :atom},
                  %Xema.Schema{items: %Xema.Schema{type: :string}, type: :list},
                  %Xema.Schema{items: %Xema.Schema{type: :atom}, type: :list},
                  %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schema"}}
                ]
              },
              type: :map
            },
            description: %Xema.Schema{type: :string},
            min_properties: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/non_negative_integer"}
            },
            pattern_properties: %Xema.Schema{
              additional_properties: %Xema.Schema{
                ref: %Xema.Ref{pointer: "#/definitions/schema"}
              },
              property_names: %Xema.Schema{
                any_of: [
                  %Xema.Schema{format: :regex, type: :string},
                  %Xema.Schema{module: Regex, type: :struct}
                ]
              },
              type: :map
            },
            minimum: %Xema.Schema{type: :number},
            properties: %Xema.Schema{
              additional_properties: %Xema.Schema{
                ref: %Xema.Ref{pointer: "#/definitions/schema"}
              },
              type: :map
            },
            definitions: %Xema.Schema{
              additional_properties: %Xema.Schema{
                ref: %Xema.Ref{pointer: "#/definitions/schema"}
              },
              type: :map
            },
            enum: %Xema.Schema{
              items: %Xema.Schema{type: true},
              min_items: 1,
              type: :list,
              unique_items: true
            },
            multiple_of: %Xema.Schema{exclusive_minimum: 0, type: :number},
            else: %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schema"}},
            all_of: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/schemas"}
            },
            max_items: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/non_negative_integer"}
            },
            contains: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/schema"}
            },
            additional_properties: %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/schema"}
            },
            default: %Xema.Schema{type: true},
            required: %Xema.Schema{
              any_of: [
                %Xema.Schema{items: %Xema.Schema{type: :string}, type: :list},
                %Xema.Schema{items: %Xema.Schema{type: :atom}, type: :list}
              ]
            },
            format: %Xema.Schema{
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
        non_negative_integer: %Xema.Schema{minimum: 0, type: :integer},
        ref: %Xema.Schema{
          items: [
            %Xema.Schema{const: :ref, type: :atom},
            %Xema.Schema{
              ref: %Xema.Ref{pointer: "#/definitions/keywords/properties/ref"}
            }
          ],
          max_length: 2,
          min_length: 2,
          type: :tuple
        },
        schema: %Xema.Schema{
          any_of: [
            %Xema.Schema{ref: %Xema.Ref{pointer: "#"}},
            %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/type"}},
            %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/types"}},
            %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/ref"}},
            %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/keywords"}},
            %Xema.Schema{module: Xema, type: :struct}
          ]
        },
        schemas: %Xema.Schema{
          items: %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/schema"}},
          type: :list
        },
        type: %Xema.Schema{
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
        types: %Xema.Schema{
          items: %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/type"}},
          type: :list
        }
      },
      items: [
        %Xema.Schema{
          any_of: [
            %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/type"}},
            %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/types"}}
          ]
        },
        %Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/keywords"}}
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
