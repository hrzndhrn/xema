defmodule Xema.Validator.Number do
  @moduledoc """
  TODO
  """

  import Xema.Helper.Error

  defmacro __using__(_) do
    quote do
      alias Xema.Validator.Number

      defp minimum(%{minimum: nil}, _number), do: :ok
      defp minimum(
        %{minimum: minimum, exclusive_minimum: exclusive_minimum},
        number
      ), do: Number.minimum(minimum, exclusive_minimum, number)

      defp maximum(%{maximum: nil}, _number), do: :ok
      defp maximum(
        %{maximum: maximum, exclusive_maximum: exclusive_maximum},
        number
      ), do: Number.maximum(maximum, exclusive_maximum, number)

      defp multiple_of(%{multiple_of: nil}, _number), do: :ok
      defp multiple_of(%{multiple_of: multiple_of}, number),
        do: Number.multiple_of(multiple_of, number)
    end
  end

  @spec minimum(number, boolean, number) :: {:error, map}
  def minimum(minimum, _exclusive, number)
    when number > minimum,
    do: :ok
  def minimum(minimum, true, number)
    when number == minimum,
    do: error(:too_small, minimum: minimum, exclusive_minimum: true)
  def minimum(minimum, _exclusive, number)
    when number == minimum,
    do: :ok
  def minimum(minimum, _exclusive, _number),
    do: error(:too_small, minimum: minimum)

  @spec maximum(number, boolean, number) :: {:error, map}
  def maximum(maximum, _exclusive, number)
    when number < maximum,
    do: :ok
  def maximum(maximum, true, number)
    when number == maximum,
    do: error(:too_big, maximum: maximum, exclusive_maximum: true)
  def maximum(maximum, _exclusive, number)
    when number == maximum,
    do: :ok
  def maximum(maximum, _exclusive, _number),
    do: error(:too_big, maximum: maximum)

  @spec multiple_of(number, number) :: :ok | {:error, map}
  def multiple_of(multiple_of, number) do
    x = number / multiple_of
    if x - Float.floor(x) == 0,
      do: :ok,
      else: error(:not_multiple, multiple_of: multiple_of)
  end
end
