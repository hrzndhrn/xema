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

  alias Xema.Utils

  @typedoc """
  The struct contains the keywords for the type `any`.

  * `as` is used in an error report. Default of `as` is `:any`
  * `enum` specifies an enumeration
  """
  @type t :: %Xema.Any{enum: list | nil, as: atom}

  defstruct [
    :all_of,
    :any_of,
    :enum,
    :exclusive_minimum,
    :minimum,
    :multiple_of,
    :not,
    :one_of,
    as: :any
  ]

  @spec new(keyword) :: Xema.Any.t()
  def new(opts \\ []), do: struct(Xema.Any, Utils.update(opts))
end
