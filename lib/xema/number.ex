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

  @spec properties(list) :: nil
  def properties(properties), do: struct(%Num{}, properties)

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(properties, number), do: validate(properties, number) == :ok

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(properties, number) do
    with :ok <- type?(number),
         :ok <- minimum?(properties, number),
         :ok <- maximum?(properties, number),
         :ok <- multiple_of?(properties, number),
         :ok <- enum?(properties, number),
      do: :ok
  end

  defp type?(number) when is_number(number), do: :ok
  defp type?(_number), do: {:error, %{type: :number}}
end
