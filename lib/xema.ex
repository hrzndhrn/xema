defmodule Xema do
  @moduledoc """
  Xema ...
  """

  defstruct type: :any, properties: nil

  @types %{
    any: Xema.Any,
    null: Xema.Null,
    boolean: Xema.Boolean,
    object: Xema.Object,
    array: Xema.Array,
    number: Xema.Number,
    string: Xema.String,
    enum: Xema.Enum
  }

  @callback is_valid?(%Xema{}, any) :: boolean
  @callback validate(%Xema{}, any) :: :ok | {:error, any}
  @callback properties(any) :: struct

  def create, do: %Xema{}

  for {type, xmodule} <- Map.to_list(@types) do
    def create(unquote(type)), do: create(unquote(type), [])
    def create(unquote(type), properties) do
      %Xema{
        type: unquote(type),
        properties: unquote(xmodule).properties(properties)
      }
    end

    def is_valid?(%Xema{type: unquote(type)} = schema, value) do
      unquote(xmodule).is_valid?(schema.properties, value)
    end

    def validate(%Xema{type: unquote(type)} = schema, value) do
      unquote(xmodule).validate(schema.properties, value)
    end
  end
end
