defmodule Xema do
  @moduledoc """
  Xema is a schema validator inspired by JSON Schema. Xema allows you to annotate
  and validate elixir data structures.

  Xema is in beta. If you try it and has an issue, report them.
  """

  defstruct [
    :id,
    :schema,
    :title,
    :description,
    :default,
    :type,
    :keywords
  ]

  @typedoc """
  The Xema base struct contains the meta data of a schema sub schema.

  * `id` a unique idenfifier.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `description` of the schema.
  * `type` of the schema.
  * `keywords` contains the specification of the schema.
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
    :number |
    :integer |
    :float |
    :string

  @type keywords ::
    Xema.Any.keywords |
    Xema.Nil.keywords |
    Xema.Boolean.keywords |
    Xema.Map.keywords |
    Xema.List.keywords |
    Xema.Number.keywords |
    Xema.Integer.keywords |
    Xema.Float.keywords |
    Xema.String.keywords

  @types %{
    any: Xema.Any,
    nil: Xema.Nil,
    boolean: Xema.Boolean,
    map: Xema.Map,
    list: Xema.List,
    number: Xema.Number,
    integer: Xema.Integer,
    float: Xema.Float,
    string: Xema.String
  }

  @callback is_valid?(Xema.t, any()) :: boolean()
  @callback validate(Xema.t, any()) :: :ok | {:error, any()}
  @callback new(keyword) :: Xema.keywords

  @spec xema(type, keyword) :: Xema.t
  @spec is_valid?(Xema.t, any) :: boolean
  @spec validate(Xema.t, any) :: :ok | {:error, any}

  def xema(type, data \\ [])

  for {type, xema_module} <- Map.to_list(@types) do
    defp create(unquote(type)), do: create(unquote(type), [])

    defp create(unquote(type), keywords) do
      with {id, keywords} <- Keyword.pop(keywords, :id),
           {schema, keywords} <- Keyword.pop(keywords, :schema),
           {title, keywords} <- Keyword.pop(keywords, :title),
           {description, keywords} <- Keyword.pop(keywords, :description),
           {default, keywords} <- Keyword.pop(keywords, :default)
      do
        %Xema{
          type: unquote(type),
          id: id,
          schema: schema,
          title: title,
          description: description,
          default: default,
          keywords: unquote(xema_module).new(keywords)
        }
      end
    end

    def xema(unquote(type), data), do: do_xema(unquote(type), data)

    defp do_xema(unquote(type)), do: create(unquote(type))
    defp do_xema({unquote(type), data}), do: create(unquote(type), do_xema(data))

    defp do_xema(unquote(type), data), do: create(unquote(type), do_xema(data))

    def is_valid?(%Xema{type: unquote(type)} = schema, value) do
      unquote(xema_module).is_valid?(schema, value)
    end

    def validate(%Xema{type: unquote(type)} = schema, value) do
      unquote(xema_module).validate(schema, value)
    end
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
end
