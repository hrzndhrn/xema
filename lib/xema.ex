defmodule Xema do
  @moduledoc """
  Xema ...
  """

  defstruct type: :any, keywords: nil

  @types %{
    any: Xema.Any,
    nil: Xema.Nil,
    boolean: Xema.Boolean,
    map: Xema.Map,
    list: Xema.List,
    number: Xema.Number,
    integer: Xema.Integer,
    float: Xema.Float,
    string: Xema.String,
    enum: Xema.Enum
  }

  @callback is_valid?(%Xema{} | nil, any) :: boolean
  @callback validate(%Xema{} | nil, any) :: :ok | {:error, any}
  @callback keywords(any) :: %Xema{} | nil

  def create, do: create(:any)

  def type(schema) do
    if schema.keywords.as != nil,
      do: schema.keywords.as,
      else: schema.type
  end

  for {type, xmodule} <- Map.to_list(@types) do
    @spec create(unquote(type)) :: %Xema{}
    def create(unquote(type)), do: create(unquote(type), [])

    @spec create(unquote(type), keyword) :: %Xema{}
    def create(unquote(type), keywords) do
      %Xema{
        type: unquote(type),
        keywords: unquote(xmodule).keywords(keywords)
      }
    end

    @spec is_valid?(%Xema{type: unquote(type)}, any) :: boolean
    def is_valid?(%Xema{type: unquote(type)} = schema, value) do
      unquote(xmodule).is_valid?(schema.keywords, value)
    end

    @spec validate(%Xema{type: unquote(type)}, any) :: :ok | {:error, any}
    def validate(%Xema{type: unquote(type)} = schema, value) do
      unquote(xmodule).validate(schema.keywords, value)
    end
  end
end
