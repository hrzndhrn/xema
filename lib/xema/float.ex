defmodule Xema.Float do
  @moduledoc """
  This module contains the struct for the keywords of type `float`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :float
      %Xema{type: %Xema.Float{}}
      iex> schema.type == %Xema.Float{}
      true
  """

  @typedoc """
  The struct contains the keywords for the type `float`.

  * `as` is used in an error report. Default of `as` is `:float`
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

  @type t :: %Xema.Float{
          minimum: integer | nil,
          maximum: integer | nil,
          exclusive_minimum: boolean | nil,
          exclusive_maximum: boolean | nil,
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
    as: :float
  ]

  @spec new(keyword) :: Xema.Float.t
  def new(opts \\ []), do: struct(Xema.Float, opts)
end
