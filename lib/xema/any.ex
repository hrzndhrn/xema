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

  import Xema.Validator.Enum

  @behaviour Xema

  defstruct [:enum, as: :any]

  @type keywords :: %Xema.Any{
    enum: list,
    as: atom
  }

  @spec new(keyword) :: Xema.Any.keywords
  def new(keywords), do: struct(Xema.Any, keywords)

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(schema, value), do: validate(schema, value) == :ok

  @spec validate(Xema.t, any) :: :ok | {:error, any}
  def validate(%Xema{keywords: keywords}, value) do
    with :ok <- enum(keywords, value),
      do: :ok
  end
end
