defmodule Xema.Integer do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  import Xema.Validator.Enum
  import Xema.Validator.Number

  import Xema.Helper.Error

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

  @spec new(keyword) :: Xema.Integer.keywords
  def new(keywords), do: struct(Xema.Integer, keywords)

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(xema, number), do: validate(xema, number) == :ok

  @spec validate(Xema.t, any) :: :ok | {:error, map}
  def validate(%Xema{keywords: keywords}, number) do
    with :ok <- type(number),
         :ok <- minimum(keywords, number),
         :ok <- maximum(keywords, number),
         :ok <- multiple_of(keywords, number),
         :ok <- enum(keywords, number),
      do: :ok
  end

  defp type(number) when is_integer(number), do: :ok
  defp type(_number), do: error(:wrong_type, type: :integer)
end
