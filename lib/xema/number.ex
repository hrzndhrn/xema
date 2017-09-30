defmodule Xema.Number do
  @moduledoc """
  TODO
  """

  @behaviour Xema

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

  @type keywords :: %Xema.Number{
    minimum: integer,
    maximum: integer,
    exclusive_minimum: boolean,
    exclusive_maximum: boolean,
    multiple_of: number,
    enum: list,
    as: atom
  }

  @spec new(keyword) :: Xema.Number.keywords
  def new(keywords), do: struct(Xema.Number, keywords)
end
