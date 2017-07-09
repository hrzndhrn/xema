defmodule Xema.Integer do
  @moduledoc """
  TODO
  """

  use Xema.Enum
  use Xema.Validator.Number

  import Xema.Error

  @behaviour Xema

  defstruct minimum: nil,
            maximum: nil,
            exclusive_maximum: nil,
            exclusive_minimum: nil,
            multiple_of: nil,
            enum: nil

  @spec keywords(keyword) :: %Xema{}
  def keywords(keywords), do: struct(%Xema.Integer{}, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(keywords, number), do: validate(keywords, number) == :ok

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
  def validate(keywords, number) do
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
