defmodule Xema.Helper.Number do
  @moduledoc """
  TODO
  """

  def minimum?(minimum, _exclusive, number)
    when number > minimum,
    do: :ok
  def minimum?(minimum, nil, number)
    when number == minimum,
    do: :ok
  def minimum?(minimum, false, number)
    when number == minimum,
    do: :ok
  def minimum?(minimum, true, number)
    when number == minimum,
    do: {:error, %{minimum: minimum, exclusive_minimum: true}}
  def minimum?(minimum, _exclusive, _number),
    do: {:error, %{minimum: minimum}}

  def maximum?(maximum, _exclusive, number)
    when number < maximum,
    do: :ok
  def maximum?(maximum, nil, number)
    when number == maximum,
    do: :ok
  def maximum?(maximum, false, number)
    when number == maximum,
    do: :ok
  def maximum?(maximum, true, number)
    when number == maximum,
    do: {:error, %{maximum: maximum, exclusive_maximum: true}}
  def maximum?(maximum, _exclusive, _number),
    do: {:error, %{maximum: maximum}}

  def multiple_of?(multiple_of, number),
    do: if _multiple_of?(multiple_of, number),
          do: :ok,
          else: {:error, %{multiple_of: multiple_of}}
  defp _multiple_of?(a, b) do
    x = b / a
    x - Float.floor(x) == 0
  end
end
