defmodule Xema.Float do
  @moduledoc """
  TODO
  """

  import Xema.Error

  use Xema.Validator.Enum
  use Xema.Validator.Number

  @behaviour Xema

  defstruct minimum: nil,
            maximum: nil,
            exclusive_maximum: nil,
            exclusive_minimum: nil,
            multiple_of: nil,
            enum: nil

  @spec keywords(keyword) :: %Xema.Float{}
  def keywords(keywords), do: struct(%Xema.Float{}, keywords)

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

  defp type(number) when is_float(number), do: :ok
  defp type(_number), do: error(:wrong_type, type: :float)
end
