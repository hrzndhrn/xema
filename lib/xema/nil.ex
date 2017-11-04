defmodule Xema.Nil do
  @moduledoc """
  This module contains the struct for the keywords of type `nil`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :nil
      %Xema{type: %Xema.Nil{}}
      iex> schema.type == %Xema.Nil{}
      true
    """

  @typedoc """
  The struct contains the keywords for the type `nil`.

  * `as` is used in an error report. Default of `as` is `:nil`
  """

  @type t :: %Xema.Nil{as: atom}

  defstruct as: nil
end
