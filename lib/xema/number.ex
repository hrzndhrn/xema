defmodule Xema.Number do
  @moduledoc """
  A validator for `number`, `float` and `integer` values.
  """

  import Xema.Validator.Enum
  import Xema.Validator.Number

  import Xema.Helper.Error

  @behaviour Xema

  defstruct [
    :minimum,
    :maximum,
    :exclusive_maximum,
    :exclusive_minimum,
    :multiple_of,
    :enum,
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

  defp type(number) when is_number(number), do: :ok
  defp type(_number), do: error(:wrong_type, type: :number)
end
