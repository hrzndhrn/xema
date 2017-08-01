defmodule Xema.Number do
  @moduledoc """
  TODO
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

  @spec new(keyword) :: %Xema.Number{}
  def new(keywords), do: struct(%Xema.Number{}, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(xema, number), do: validate(xema, number) == :ok

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
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
