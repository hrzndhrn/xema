defmodule Xema.String do
  @moduledoc """
  This module contains the struct for the keywords of type `string`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :string
      %Xema{type: %Xema.String{}}
      iex> schema.type == %Xema.String{}
      true
  """

  @typedoc """
  The struct contains the keywords for the type `string`.

  * `as` is used in an error report. Default of `as` is `:string`
  * `enum` specifies an enumeration
  * `max_length` maximum length of string
  * `min_length` minimal length of string
  """
  @type t :: %Xema.String{
          max_length: pos_integer | nil,
          min_length: pos_integer | nil,
          pattern: Regex.t() | nil,
          enum: list | nil,
          as: atom
        }

  defstruct [
    :max_length,
    :min_length,
    :pattern,
    :enum,
    as: :string
  ]
end
