defmodule Xema.Float do
  @moduledoc """
  TODO
  """

  import Xema.Error

  @behaviour Xema

  defstruct minimum: nil,
            maximum: nil,
            exclusive_maximum: nil,
            exclusive_minimum: nil,
            multiple_of: nil,
            enum: nil

  alias Xema.Float

  use Xema.Enum
  use Xema.Validator.Number

  @spec keywords(list) :: nil
  def keywords(keywords), do: struct(%Float{}, keywords)

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(keywords, number), do: validate(keywords, number) == :ok

  @spec validate(nil, any) :: :ok | {:error, map}
  def validate(keywords, number) do
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
