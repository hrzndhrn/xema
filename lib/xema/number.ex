defmodule Xema.Number do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct minimum: nil,
            maximum: nil,
            exclusive_maximum: nil,
            exclusive_minimum: nil,
            multiple_of: nil,
            enum: nil

  alias Xema.Number, as: Num

  use Xema.Enum
  use Xema.Validator.Number

  @spec keywords(list) :: nil
  def keywords(keywords), do: struct(%Num{}, keywords)

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(keywords, number), do: validate(keywords, number) == :ok

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(keywords, number) do
    with :ok <- type(number),
         :ok <- minimum(keywords, number),
         :ok <- maximum(keywords, number),
         :ok <- multiple_of(keywords, number),
         :ok <- enum(keywords, number),
      do: :ok
  end

  defp type(number) when is_number(number), do: :ok
  defp type(_number), do: {:error, :wrong_type, %{type: :number}}
end
