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

  @type keywords :: %Xema.Integer{
    minimum: integer,
    maximum: integer,
    exclusive_minimum: boolean,
    exclusive_maximum: boolean,
    multiple_of: number,
    enum: list,
    as: atom
  }

  def new(keywords), do: struct(Xema.Integer, keywords)

  def bla, do: "bla"
end
