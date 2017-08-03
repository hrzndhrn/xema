defmodule Xema.Validator.Enum do
  @moduledoc """
  A validator for enumerations.
  """

  import Xema.Helper.Error

  @doc """
  Checks if `element` in `enum`.

  Returns `:ok` if the keyword `enum` is missing. If `enum` is defined in
  keywords the function checks if `element` exists in the enumeration.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :any, enum: [1, 2]
      %Xema{type: :any, id: nil, schema: nil, title: nil, description: nil,
        keywords: %Xema.Any{as: :any, enum: [1, 2]}}
      iex> Xema.Validator.Enum.enum(schema.keywords, 1)
      :ok
      iex> Xema.Validator.Enum.enum(schema.keywords, 7)
      {:error, %{reason: :not_in_enum, element: 7, enum: [1, 2]}}

  """
  @spec enum(Xema.keywords, any) :: :ok | {:error, map()}
  def enum(%{enum: nil} = _keywords, _element), do: :ok
  def enum(%{enum: enum}, element) do
    if Enum.member?(enum, element),
      do: :ok,
      else: error(:not_in_enum, enum: enum, element: element)
  end
end
