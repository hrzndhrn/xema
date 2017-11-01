defmodule Xema.String do
  @moduledoc """
  This module contains the struct for the keywords of the type `string`.

  Supported keywords:
  * `enum` specifies an enumeration

  `as` is an atom that is used in an error report. Default of `as` is `:string`.

  Usualy this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :string
      %Xema{type: %Xema.String{}}
      iex> schema.type == %Xema.String{}
      true
  """

  defstruct [
    :max_length,
    :min_length,
    :pattern,
    :enum,
    as: :string
  ]

  @type t :: %Xema.String{
    max_length: pos_integer | nil,
    min_length: pos_integer | nil,
    pattern: Regex.t | nil,
    enum: list | nil,
    as: atom
  }
end
