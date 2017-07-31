defmodule Xema do
  @moduledoc """
  Xema ...
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

  @callback is_valid?(%Xema{}, any()) :: boolean()
  @callback validate(%Xema{}, any()) :: :ok | {:error, any()}
  @callback new(keyword()) :: struct()

  @spec type(%Xema{}) :: atom
  def type(schema) do
    if schema.keywords.as != nil,
      do: schema.keywords.as,
      else: schema.type
  end

  for {type, xema_module} <- Map.to_list(@types) do
    @spec create(unquote(type)) :: %Xema{}
    defp create(unquote(type)), do: create(unquote(type), [])

    @spec create(unquote(type), any()) :: %Xema{}
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

    @spec xema(unquote(type) | {unquote(type), any()}) :: %Xema{} | keyword()
    def xema(unquote(type)), do: create(unquote(type))
    def xema({unquote(type), data}), do: create(unquote(type), xema(data))

    @spec xema(unquote(type), any()) :: %Xema{} | keyword()
    def xema(unquote(type), data), do: create(unquote(type), xema(data))

    @spec is_valid?(%Xema{type: unquote(type)}, any()) :: boolean
    def is_valid?(%Xema{type: unquote(type)} = schema, value) do
      unquote(xema_module).is_valid?(schema, value)
    end

    @spec validate(%Xema{type: unquote(type)}, any()) :: :ok | {:error, any}
    def validate(%Xema{type: unquote(type)} = schema, value) do
      unquote(xema_module).validate(schema, value)
    end
  end

  def xema(data) when is_list(data), do: Enum.map(data, &map_values/1)
  def xema(data) when is_map(data), do: Enum.into(data, %{}, &map_values/1)
  def xema(data), do: data

  defp map_values({key, value}), do: {key, xema(value)}
end
