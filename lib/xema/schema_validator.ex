defmodule Xema.SchemaValidator do
  @moduledoc """
  A validator for the schema input.
  """

  # credo:disable-for-this-file Credo.Check.Design.DuplicatedCode

  alias Xema.{Ref, Schema, SchemaError}

  defp schema,
    do:
      struct(Xema,
        refs: %{
          "#/definitions/keywords" => %Schema{
            properties: %{
              examples: %Schema{
                items: %Schema{type: true},
                type: :list
              },
              format: %Schema{type: :atom},
              if: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
              exclusive_minimum: %Schema{type: [:boolean, :number]},
              max_length: %Schema{
                ref: %Ref{pointer: "#/definitions/non_negative_integer"}
              },
              max_items: %Schema{
                ref: %Ref{pointer: "#/definitions/non_negative_integer"}
              },
              any_of: %Schema{
                ref: %Ref{pointer: "#/definitions/schemas"}
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
              const: %Schema{type: true},
              description: %Schema{type: :string},
              one_of: %Schema{
                ref: %Ref{pointer: "#/definitions/schemas"}
              },
              properties: %Schema{
                additional_properties: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                type: :map
              },
              id: %Schema{format: :uri_reference, type: :string},
              pattern: %Schema{
                any_of: [
                  %Schema{format: :regex, type: :string},
                  %Schema{module: Regex, type: :struct}
                ]
              },
              else: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              items: %Schema{
                any_of: [
                  %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
                  %Schema{ref: %Ref{pointer: "#/definitions/schemas"}}
                ]
              },
              comment: %Schema{type: :string},
              exclusive_maximum: %Schema{type: [:boolean, :number]},
              default: %Schema{type: true},
              minimum: %Schema{type: :number},
              ref: %Schema{format: :uri_reference, type: :string},
              maximum: %Schema{type: :number},
              min_items: %Schema{
                ref: %Ref{pointer: "#/definitions/non_negative_integer"}
              },
              min_length: %Schema{
                ref: %Ref{pointer: "#/definitions/non_negative_integer"}
              },
              title: %Schema{type: :string},
              enum: %Schema{
                items: %Schema{type: true},
                min_items: 1,
                type: :list,
                unique_items: true
              },
              unique_items: %Schema{type: :boolean},
              then: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              contains: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              min_properties: %Schema{
                ref: %Ref{pointer: "#/definitions/non_negative_integer"}
              },
              multiple_of: %Schema{exclusive_minimum: 0, type: :number},
              property_names: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              required: %Schema{
                any_of: [
                  %Schema{items: %Schema{type: :string}, type: :list},
                  %Schema{items: %Schema{type: :atom}, type: :list}
                ]
              },
              dependencies: %Schema{
                additional_properties: %Schema{
                  any_of: [
                    %Schema{type: :string},
                    %Schema{type: :atom},
                    %Schema{
                      items: %Schema{type: :string},
                      type: :list
                    },
                    %Schema{items: %Schema{type: :atom}, type: :list},
                    %Schema{
                      ref: %Ref{pointer: "#/definitions/schema"}
                    }
                  ]
                },
                type: :map
              },
              schema: %Schema{format: :uri, type: :string},
              max_properties: %Schema{
                ref: %Ref{pointer: "#/definitions/non_negative_integer"}
              },
              not: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
              additional_properties: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              additional_items: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
              definitions: %Schema{
                additional_properties: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                type: :map
              },
              all_of: %Schema{
                ref: %Ref{pointer: "#/definitions/schemas"}
              }
            },
            type: :keyword
          },
          "#/definitions/keywords/properties/ref" => %Schema{
            format: :uri_reference,
            type: :string
          },
          "#/definitions/non_negative_integer" => %Schema{
            minimum: 0,
            type: :integer
          },
          "#/definitions/ref" => %Schema{
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
          "#/definitions/schema" => %Schema{
            any_of: [
              %Schema{ref: %Ref{pointer: "#"}},
              %Schema{ref: %Ref{pointer: "#/definitions/type"}},
              %Schema{ref: %Ref{pointer: "#/definitions/types"}},
              %Schema{ref: %Ref{pointer: "#/definitions/ref"}},
              %Schema{ref: %Ref{pointer: "#/definitions/keywords"}},
              %Schema{module: Xema, type: :struct},
              %Schema{type: :atom}
            ]
          },
          "#/definitions/schemas" => %Schema{
            items: %Schema{ref: %Ref{pointer: "#/definitions/schema"}},
            type: :list
          },
          "#/definitions/type" => %Schema{
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
          "#/definitions/types" => %Schema{
            items: %Schema{ref: %Ref{pointer: "#/definitions/type"}},
            type: :list
          }
        },
        schema: %Schema{
          definitions: %{
            keywords: %Schema{
              properties: %{
                examples: %Schema{
                  items: %Schema{type: true},
                  type: :list
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
                },
                if: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                exclusive_minimum: %Schema{type: [:boolean, :number]},
                max_length: %Schema{
                  ref: %Ref{pointer: "#/definitions/non_negative_integer"}
                },
                max_items: %Schema{
                  ref: %Ref{pointer: "#/definitions/non_negative_integer"}
                },
                any_of: %Schema{
                  ref: %Ref{pointer: "#/definitions/schemas"}
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
                const: %Schema{type: true},
                description: %Schema{type: :string},
                one_of: %Schema{
                  ref: %Ref{pointer: "#/definitions/schemas"}
                },
                properties: %Schema{
                  additional_properties: %Schema{
                    ref: %Ref{pointer: "#/definitions/schema"}
                  },
                  type: :map
                },
                id: %Schema{format: :uri_reference, type: :string},
                pattern: %Schema{
                  any_of: [
                    %Schema{format: :regex, type: :string},
                    %Schema{module: Regex, type: :struct}
                  ]
                },
                else: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                items: %Schema{
                  any_of: [
                    %Schema{
                      ref: %Ref{pointer: "#/definitions/schema"}
                    },
                    %Schema{
                      ref: %Ref{pointer: "#/definitions/schemas"}
                    }
                  ]
                },
                comment: %Schema{type: :string},
                exclusive_maximum: %Schema{type: [:boolean, :number]},
                default: %Schema{type: true},
                minimum: %Schema{type: :number},
                ref: %Schema{format: :uri_reference, type: :string},
                maximum: %Schema{type: :number},
                min_items: %Schema{
                  ref: %Ref{pointer: "#/definitions/non_negative_integer"}
                },
                min_length: %Schema{
                  ref: %Ref{pointer: "#/definitions/non_negative_integer"}
                },
                title: %Schema{type: :string},
                enum: %Schema{
                  items: %Schema{type: true},
                  min_items: 1,
                  type: :list,
                  unique_items: true
                },
                unique_items: %Schema{type: :boolean},
                then: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                contains: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                min_properties: %Schema{
                  ref: %Ref{pointer: "#/definitions/non_negative_integer"}
                },
                multiple_of: %Schema{exclusive_minimum: 0, type: :number},
                property_names: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                required: %Schema{
                  any_of: [
                    %Schema{
                      items: %Schema{type: :string},
                      type: :list
                    },
                    %Schema{items: %Schema{type: :atom}, type: :list}
                  ]
                },
                dependencies: %Schema{
                  additional_properties: %Schema{
                    any_of: [
                      %Schema{type: :string},
                      %Schema{type: :atom},
                      %Schema{
                        items: %Schema{type: :string},
                        type: :list
                      },
                      %Schema{
                        items: %Schema{type: :atom},
                        type: :list
                      },
                      %Schema{
                        ref: %Ref{pointer: "#/definitions/schema"}
                      }
                    ]
                  },
                  type: :map
                },
                schema: %Schema{format: :uri, type: :string},
                max_properties: %Schema{
                  ref: %Ref{pointer: "#/definitions/non_negative_integer"}
                },
                not: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                additional_properties: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                additional_items: %Schema{
                  ref: %Ref{pointer: "#/definitions/schema"}
                },
                definitions: %Schema{
                  additional_properties: %Schema{
                    ref: %Ref{pointer: "#/definitions/schema"}
                  },
                  type: :map
                },
                all_of: %Schema{
                  ref: %Ref{pointer: "#/definitions/schemas"}
                }
              },
              type: :keyword
            },
            non_negative_integer: %Schema{minimum: 0, type: :integer},
            ref: %Schema{
              items: [
                %Schema{const: :ref, type: :atom},
                %Schema{
                  ref: %Ref{
                    pointer: "#/definitions/keywords/properties/ref"
                  }
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
              items: %Schema{
                ref: %Ref{pointer: "#/definitions/schema"}
              },
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
      )

  @doc """
  Returns `:ok` if the data valid against the xema schema.
  """
  @spec validate!(any) :: :ok
  def validate!(data) do
    case Xema.validate(schema(), data, []) do
      :ok ->
        :ok

      {:error, reason} ->
        raise SchemaError, reason
    end
  end
end
