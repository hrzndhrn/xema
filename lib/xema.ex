defmodule Xema do
  @moduledoc """
  Xema ...
  """

  defstruct type: :any, properties: nil

  @types %{
    any: Xema.Any,
    null: Xema.Null,
    nil: Xema.Nil,
    boolean: Xema.Boolean,
    object: Xema.Object,
    array: Xema.Array,
    number: Xema.Number,
    string: Xema.String,
    enum: Xema.Enum
  }

  @callback is_valid?(%Xema{} | nil, any) :: boolean
  @callback validate(%Xema{} | nil, any) :: :ok | {:error, any}
  @callback properties(any) :: %Xema{} | nil

  def create, do: create(:any)

  for {type, xmodule} <- Map.to_list(@types) do
    @spec create(unquote(type)) :: %Xema{}
    def create(unquote(type)), do: create(unquote(type), [])

    @spec create(unquote(type), keyword) :: %Xema{}
    def create(unquote(type), properties) do
      %Xema{
        type: unquote(type),
        properties: unquote(xmodule).properties(properties)
      }
    end

    @spec is_valid?(%Xema{type: unquote(type)}, any) :: boolean
    def is_valid?(%Xema{type: unquote(type)} = schema, value) do
      unquote(xmodule).is_valid?(schema.properties, value)
    end

    @spec validate(%Xema{type: unquote(type)}, any) :: :ok | {:error, any}
    def validate(%Xema{type: unquote(type)} = schema, value) do
      unquote(xmodule).validate(schema.properties, value)
    end
  end
end
