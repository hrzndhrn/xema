defmodule Xema.Number do
  @moduledoc """
  TODO
  """

  alias Xema.Number
  alias Xema.Validator.Number, as: Validator

  @behaviour Xema

  defstruct minimum: nil,
            maximum: nil,
            exclusive_maximum: nil,
            exclusive_minimum: nil,
            multiple_of: nil

  @spec properties(list) :: nil
  def properties(properties), do: struct(%Number{}, properties)

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

  defp type?(number)
    when is_number(number),
    do: :ok
  defp type?(_number), do: {:error, %{type: :number}}

  defp minimum?(%Number{minimum: nil}, _number), do: :ok
  defp minimum?(
    %Xema.Number{minimum: minimum, exclusive_minimum: exclusive_minimum},
    number
  ), do: Validator.minimum?(minimum, exclusive_minimum, number)

  defp maximum?(%Number{maximum: nil}, _number), do: :ok
  defp maximum?(
    %Xema.Number{maximum: maximum, exclusive_maximum: exclusive_maximum},
    number
  ), do: Validator.maximum?(maximum, exclusive_maximum, number)

  defp multiple_of?(%Number{multiple_of: nil}, _number), do: :ok
  defp multiple_of?(%Number{multiple_of: multiple_of}, number),
    do: Validator.multiple_of?(multiple_of, number)
end
