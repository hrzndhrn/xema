defmodule Xema.Validator.Number do
  @moduledoc """
  TODO
  """

  import Xema.Helper.Error

  @spec minimum(struct(), any()) :: :ok | {:error, map()}
  def minimum(%{minimum: nil}, _number), do: :ok
  def minimum(
    %{minimum: minimum, exclusive_minimum: exclusive_minimum},
    number
  ), do: minimum(minimum, exclusive_minimum, number)

  @spec maximum(struct(), any()) :: :ok | {:error, map()}
  def maximum(%{maximum: nil}, _number), do: :ok
  def maximum(
    %{maximum: maximum, exclusive_maximum: exclusive_maximum},
    number
  ), do: maximum(maximum, exclusive_maximum, number)

  @spec multiple_of(struct(), any) :: :ok | {:error, map}
  def multiple_of(%{multiple_of: nil}, _number), do: :ok
  def multiple_of(%{multiple_of: multiple_of}, number) do
    x = number / multiple_of
    if x - Float.floor(x) == 0,
      do: :ok,
      else: error(:not_multiple, multiple_of: multiple_of)
  end

  defp minimum(minimum, _exclusive, number)
    when number > minimum,
    do: :ok
  defp minimum(minimum, true, number)
    when number == minimum,
    do: error(:too_small, minimum: minimum, exclusive_minimum: true)
  defp minimum(minimum, _exclusive, number)
    when number == minimum,
    do: :ok
  defp minimum(minimum, _exclusive, _number),
    do: error(:too_small, minimum: minimum)

  defp maximum(maximum, _exclusive, number)
    when number < maximum,
    do: :ok
  defp maximum(maximum, true, number)
    when number == maximum,
    do: error(:too_big, maximum: maximum, exclusive_maximum: true)
  defp maximum(maximum, _exclusive, number)
    when number == maximum,
    do: :ok
  defp maximum(maximum, _exclusive, _number),
    do: error(:too_big, maximum: maximum)
end
