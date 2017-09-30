defmodule Xema.Any do
  @moduledoc """
  This module contains the keywords and validation functions for an `any`
  schema.

  Supported keywords:
  * `enum` specifies an enumeration.

  `as` can be an atom that will be report in an error case as type of the
  schema. Default of `as` is `:float`

  ## Examples

      iex> import Xema
      Xema
      iex> any = xema :any, enum: [1, "a", :b]
      %Xema{
        default: nil,
        description: nil,
        id: nil,
        keywords: %Xema.Any{
          as: :any,
          enum: [1, "a", :b]
        },
        schema: nil,
        title: nil,
        type: :any
      }
      iex> validate(any, "a")
      :ok
      iex> validate(any, :foo)
      {:error, %{element: :foo, enum: [1, "a", :b], reason: :not_in_enum}}
  """

  @behaviour Xema

  defstruct [:enum, as: :any]

  @type t :: %Xema.Any{enum: list, as: atom}

  @spec new(keyword) :: Xema.Any.t
  def new(keywords), do: struct(Xema.Any, keywords)
end
