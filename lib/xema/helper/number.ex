defmodule Xema.Helper.Number do
  @moduledoc """
  TODO
  """

  def minimum?(nil, nil, _number), do: :ok
  def minimum?(minimum, true, number) do
    cond do
      number > minimum ->
        :ok
      number == minimum ->
        {:error, %{minimum: minimum, exclusive_minimum: true}}
      true ->
        {:error, %{minimum: minimum}}
    end
  end
  def minimum?(minimum, nil, number),
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
