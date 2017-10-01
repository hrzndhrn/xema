defmodule Xema.Number do
  @moduledoc """
  TODO
  """

  defstruct [
    :minimum,
    :maximum,
    :exclusive_maximum,
    :exclusive_minimum,
    :multiple_of,
    :enum,
    type: :number,
    as: :number
  ]

  @type t :: %Xema.Number{
    minimum: integer | nil,
    maximum: integer | nil,
    exclusive_minimum: boolean | nil,
    exclusive_maximum: boolean | nil,
    multiple_of: number | nil,
    enum: list | nil,
    as: atom
  }
end
