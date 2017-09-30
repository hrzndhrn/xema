defmodule Xema.String do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct [
    :max_length,
    :min_length,
    :pattern,
    :enum,
    as: :string
  ]

  @type t :: %Xema.String{
    max_length: pos_integer,
    min_length: pos_integer,
    pattern: Regex.t,
    enum: list,
    as: atom
  }

  @spec new(list) :: Xema.String.t
  def new(keywords), do: struct(Xema.String, keywords)
end
