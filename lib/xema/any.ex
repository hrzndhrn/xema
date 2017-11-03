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

  defstruct [:enum, as: :any]
end
