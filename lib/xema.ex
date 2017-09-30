defmodule Xema do
  @moduledoc """
  Xema is a schema validator inspired by JSON Schema.

  Xema allows you to annotate and validate elixir data structures.

  Xema is in beta. If you try it and has an issue, report them.
  """

  alias Xema.Validator

  defstruct [
    :id,
    :schema,
    :title,
    :description,
    :type,
    :keywords
  ]

  @typedoc """
  The Xema base struct contains the meta data of a schema sub schema.

  * `id` a unique idenfifier.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `description` of the schema.
  * `type` contains the specification of the schema.
  """
  @type t :: %Xema{
    id: String.t,
    schema: String.t,
    title: String.t,
    description: String.t,
    type: type,
    keywords: any
  }

  @typedoc """
  The available type notations.
  """
  @type type ::
    :nil |
    :any |
    :boolean |
    :map |
    :list |
    :string |
    :number |
    :float |
    :integer

  @typedoc """
  The `keywords` for the schema types.
  """
  @type types ::
    Xema.Any.keywords |
    Xema.Nil.t |
    Xema.Boolean.keywords |
    Xema.Map.keywords |
    Xema.List.keywords |
    Xema.Number.keywords |
    Xema.String.keywords

  @types %{
    any: Xema.Any,
    nil: Xema.Nil,
    boolean: Xema.Boolean,
    map: Xema.Map,
    list: Xema.List,
    string: Xema.String,
    number: Xema.Number,
    float: Xema.Float,
    integer: Xema.Integer
  }

  @callback new(keyword) :: Xema.types

  @doc """
  This function defines the schemas.

  The first argument sets the `type` of the schema. The second arguments
  contains the keywords of the schema.

  ## Parameters

    - type: type of the schema.
    - opts: keywords of the schema.

  ## Examples

      iex> import Xema
      Xema
      iex> xema :string, min_length: 3, max_length: 12
      %Xema{
        type: :string,
        keywords: %Xema.String.Keywords{
          max_length: 12,
          min_length: 3,
        }
      }

  For nested schema you can use `{:type, opts: ...}` like here.

  ## Examples
      iex> import Xema
      Xema
      iex> schema = xema :list, items: {:number, minimum: 2}
      %Xema{
        type: :list,
        keywords: %Xema.List{
          items: %Xema{
            type: :number,
            keywords: %Xema.Number{
              minimum: 2
            }
          }
        }
      }
      iex> validate(schema, [2, 3, 4])
      :ok

  """
  @spec xema(type, keyword) :: Xema.t
  def xema(type, data \\ [])

  @spec is_valid?(Xema.t, any) :: boolean
  @spec validate(Xema.t, any) :: :ok | {:error, any}

  for {type, xema_module} <- Map.to_list(@types) do
    defp create(unquote(type)), do: create(unquote(type), [])

    defp create(unquote(type), keywords) do
      with {id, keywords} <- Keyword.pop(keywords, :id),
           {schema, keywords} <- Keyword.pop(keywords, :schema),
           {title, keywords} <- Keyword.pop(keywords, :title),
           {description, keywords} <- Keyword.pop(keywords, :description)
      do
        %Xema{
          id: id,
          schema: schema,
          title: title,
          description: description,
          type: unquote(xema_module).new(keywords)
        }
      end
    end

    def create_keywords(unquote(type), opts) do
      # struct(unquote(xema_module), opts)
      unquote(xema_module).new(opts)
    end



    def xema(unquote(type), opts), do: do_xema(unquote(type), opts)

    defp do_xema(unquote(type)), do: create(unquote(type))
    defp do_xema({unquote(type), data}), do: create(unquote(type), do_xema(data))
    defp do_xema(unquote(type), data), do: create(unquote(type), do_xema(data))

    #def is_valid?(%Xema{type: unquote(type)} = schema, value) do
    #  unquote(xema_module).is_valid?(schema, value)
    #end

    #def validate(%Xema{type: unquote(type)} = schema, value) do
    #  unquote(xema_module).validate(schema, value)
    #end

    #def xvalidate(%Xema{keywords: %unquote(xema_module).Keywords{}} = schema, value) do
    #  unquote(xema_module).validate(schema, value)
    #end
  end

  defp do_xema(data) when is_list(data), do: Enum.map(data, &map_values/1)
  defp do_xema(data) when is_map(data), do: Enum.into(data, %{}, &map_values/1)
  defp do_xema(data), do: data

  defp map_values({_keyword, %Xema{}} = data), do: data
  defp map_values({keyword, _value} = data)
    when keyword in [:required, :enum, :keys, :pattern],
    do: data
  defp map_values({:properties, map}),
    do: {:properties, Enum.into(map, %{}, &do_map_values/1)}
  defp map_values({:items, list}) when is_list(list),
    do: {:items, Enum.map(list, &do_xema/1)}
  defp map_values({:dependencies, data}) do
    {
      :dependencies,
      Enum.into(data, %{}, fn {key, value} ->
        if is_list(value), do: {key, value}, else: {key, do_xema(value)}
      end)
    }
  end
  defp map_values(data), do: do_map_values(data)

  defp do_map_values({key, value}), do: {key, do_xema(value)}

  def is_valid?(xema, value), do: validate(xema, value) == :ok
  def validate(xema, value), do: Validator.validate(xema, value)

end
