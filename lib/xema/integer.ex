defmodule Xema.Integer do
  @moduledoc """
  TODO
  """

  alias Xema.Helper.Number, as: Integer
  #use Xema.Helper.Number

  @behaviour Xema

  defstruct minimum: nil,
            maximum: nil,
            exclusive_maximum: nil,
            exclusive_minimum: nil,
            multiple_of: nil

  @spec properties(list) :: nil
  def properties(properties), do: struct(%Xema.Integer{}, properties)

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(properties, number), do: validate(properties, number) == :ok

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(properties, number) do
    with :ok <- type?(number),
         :ok <- minimum?(properties, number),
         :ok <- maximum?(properties, number),
         :ok <- multiple_of?(properties, number),
      do: :ok
  end

  defp type?(number) when is_integer(number), do: :ok
  defp type?(_number), do: {:error, %{type: :integer}}

  # defp minimum?(%Xema.Integer{minimum: nil}, _number), do: :ok
  defp minimum?(%{minimum: nil}, _number), do: :ok
  defp minimum?(
    %{minimum: minimum, exclusive_minimum: exclusive_minimum},
    number
  ), do: Integer.minimum?(minimum, exclusive_minimum, number)

  defp maximum?(%{maximum: nil}, _number), do: :ok
  defp maximum?(
    %{maximum: maximum, exclusive_maximum: exclusive_maximum},
    number
  ), do: Integer.maximum?(maximum, exclusive_maximum, number)

  defp multiple_of?(%{multiple_of: nil}, _number), do: :ok
  defp multiple_of?(%{multiple_of: multiple_of}, number),
    do: Integer.multiple_of?(multiple_of, number)
end
