defmodule Xema do
  @doc """
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
  @callback properties(any) :: struct

  def create(), do: %Xema{}
  def create(:string, properties \\ []) do
    %Xema{type: :string, properties: Xema.String.properties(properties)}
  end

  for {type, xmodule} <- Map.to_list(@types) do
    def is_valid?(%Xema{type: unquote(type)} = schema, value) do
      unquote(xmodule).is_valid?(schema, value)
    end
  end
end
