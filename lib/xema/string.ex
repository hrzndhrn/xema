defmodule Xema.String do
  @moduledoc """
  TODO
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
