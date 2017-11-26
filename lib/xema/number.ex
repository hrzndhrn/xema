defmodule Xema.Number do
  @moduledoc """
  This module contains the struct for the keywords of type `number`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :number
      %Xema{type: %Xema.Number{}}
      iex> schema.type == %Xema.Number{}
      true
  """

  @typedoc """
  The struct contains the keywords for the type `number`.

  * `as` is used in an error report. Default of `as` is `:number`
  * `enum` specifies an enumeration
  * `exclusive_maximum` is a boolean. When true, it indicates that the range
    excludes the maximum value.
  * `exclusive_minimum` is a boolean. When true, it indicates that the range
    excludes the minimum value.
  * `maximum` the maximum value
  * `minimum` the minimum value
  * `multiple_of` is a number greater 0. The value has to be a multiple of this
    number.
  """

  @type t :: %Xema.Number{
          minimum: number | nil,
          maximum: number | nil,
          exclusive_minimum: boolean | number | nil,
          exclusive_maximum: boolean | number | nil,
          multiple_of: number | nil,
          enum: list | nil,
          as: atom
        }

  defstruct [
    :minimum,
    :maximum,
    :exclusive_maximum,
    :exclusive_minimum,
    :multiple_of,
    :enum,
    type: :number,
    as: :number
  ]

  @spec new(keyword) :: Xema.Number.t()
  def new(opts \\ []), do: struct(Xema.Number, opts)
end
