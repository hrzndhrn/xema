defmodule Xema.Boolean do
  @moduledoc """
  This module contains the struct for the keywords of type `boolean`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :boolean
      %Xema{type: %Xema.Boolean{}}
      iex> schema.type == %Xema.Boolean{}
      true
  """

  @typedoc """
  The struct contains the keywords for the type `boolean`.

  * `as` is used in an error report. Default of `as` is `:boolean`
  """

  @type t :: %Xema.Boolean{as: atom}

  defstruct as: :boolean

  @spec new(keyword) :: Xema.Boolean.t()
  def new(opts \\ []), do: struct(Xema.Boolean, opts)
end
