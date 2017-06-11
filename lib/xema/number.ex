defmodule Xema.Number do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct minimum: nil,
            maximum: nil,
            exclusive_maximum: nil,
            exclusive_minimum: nil,
            multiple_of: nil

  @spec properties(list) :: nil
  def properties(properties), do: struct(%Xema.Number{}, properties)

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

  defp type?(number),
    do: if is_integer(number) || is_float(number),
          do: :ok,
          else: {:error, %{type: :number}}

  defp minimum?(%Xema.Number{minimum: nil}, _number), do: :ok
  defp minimum?(
    %Xema.Number{minimum: minimum, exclusive_minimum: true},
    number
  ) do
    cond do
      number > minimum ->
        :ok
      number == minimum ->
        {:error, %{minimum: minimum, exclusive_minimum: true}}
      true ->
        {:error, %{minimum: minimum}}
    end
  end
  defp minimum?(%Xema.Number{minimum: minimum}, number),
    do: if number >= minimum,
          do: :ok,
          else: {:error, %{minimum: minimum}}

  defp maximum?(%Xema.Number{maximum: nil}, _number), do: :ok
  defp maximum?(
    %Xema.Number{maximum: maximum, exclusive_maximum: true},
    number
  ) do
    cond do
      number < maximum ->
        :ok
      number == maximum ->
        {:error, %{maximum: maximum, exclusive_maximum: true}}
      true ->
        {:error, %{maximum: maximum}}
    end
  end
  defp maximum?(%Xema.Number{maximum: maximum}, number),
    do: if number <= maximum,
          do: :ok,
          else: {:error, %{maximum: maximum}}

  defp multiple_of?(%Xema.Number{multiple_of: nil}, _number), do: :ok
  defp multiple_of?(%Xema.Number{multiple_of: multiple_of}, number),
    do: if multiple_of?(number, multiple_of),
          do: :ok,
          else: {:error, %{multiple_of: multiple_of}}
  defp multiple_of?(a, b) do
    x = a / b
    x - Float.floor(x) == 0
  end
end
