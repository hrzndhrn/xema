defmodule Xema.Integer do
  @moduledoc false

  defstruct [
    :minimum,
    :maximum,
    :exclusive_maximum,
    :exclusive_minimum,
    :multiple_of,
    :enum,
    as: :integer
  ]

  @type t :: %Xema.Integer{
    minimum: integer | nil,
    maximum: integer | nil,
    exclusive_minimum: boolean | nil,
    exclusive_maximum: boolean | nil,
    multiple_of: number | nil,
    enum: list | nil,
    as: atom
  }
end
