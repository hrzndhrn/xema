defmodule Xema.Any do
  @moduledoc """
  This module contains the struct for the keywords of type `any`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :any
      %Xema{type: %Xema.Any{}}
      iex> schema.type == %Xema.Any{}
      true
  """

  @typedoc """
  The struct contains the keywords for the type `any`.

  * `as` is used in an error report. Default of `as` is `:any`
  * `enum` specifies an enumeration
  """
  @type t :: %Xema.Any{enum: list | nil, as: atom}

  defstruct [:all_of, :any_of, :enum, :not, :one_of, as: :any]

  @spec new(keyword) :: Xema.Any.t()
  def new(opts \\ []), do: struct(Xema.Any, update(opts))

  defp update(opts) do
    opts
    |> Keyword.update(:all_of, nil, &schemas/1)
    |> Keyword.update(:any_of, nil, &schemas/1)
    |> Keyword.update(:not, nil, fn schema -> Xema.type(schema) end)
    |> Keyword.update(:one_of, nil, &schemas/1)
  end

  defp schemas(list), do: Enum.map(list, fn schema -> Xema.type(schema) end)
end
