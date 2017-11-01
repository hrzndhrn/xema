defmodule Xema.Any do
  @moduledoc """
  This module contains the struct for the keywords of the type `any`.

  Usualy this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :any
      %Xema{type: %Xema.Any{}}
      iex> schema.type == %Xema.Any{}
      true
  """

  defstruct [:enum, as: :any]

  @typedoc """
  The struct contains tke keywords for the type `any`.

  * `enum` specifies an enumeration
  * `as` is used in an error report. Default of `as` is `:any`.
  """
  @type t :: %Xema.Any{enum: list | nil, as: atom}
end
