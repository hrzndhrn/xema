defmodule Xema.Validator.Number do
  @moduledoc """
  A validator for numbers.
  """

  import Xema.Helper.Error

  @doc """
  Checks if the number is bigger as the given minimum.

  Checks if the keywords contains `minimum` and `exclusive_minimum`. Returns :ok
  if not one of the keywords was found. Otherwise the function checks if the
  minimum holds.

  `exclusive_minimum` is just allowed but otional if `minimum` is set.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :number, minimum: 5, exclusive_minimum: true
      %Xema{
        type: :number,
        schema: :nil,
        id: nil,
        title: nil,
        description: nil,
        keywords: %Xema.Number{
          as: :number,
          enum: nil,
          exclusive_maximum: nil,
          exclusive_minimum: true,
          maximum: nil,
          minimum: 5,
          multiple_of: nil
        }
      }
      iex> Xema.Validator.Number.minimum(schema.keywords, 9)
      :ok
      iex> Xema.Validator.Number.minimum(schema.keywords, 1)
      {:error, %{minimum: 5, reason: :too_small}}
      iex> Xema.Validator.Number.minimum(schema.keywords, 5)
      {:error, %{minimum: 5, reason: :too_small, exclusive_minimum: true}}

  """
  @spec minimum(Xema.keywords, number) :: :ok | {:error, map()}
  def minimum(%{minimum: nil} = _keywords, _number), do: :ok
  def minimum(
    %{minimum: minimum, exclusive_minimum: exclusive_minimum},
    number
  ), do: minimum(minimum, exclusive_minimum, number)

  @spec maximum(Xema.keywords, number) :: :ok | {:error, map()}
  def maximum(%{maximum: nil} = _keywords, _number), do: :ok
  def maximum(
    %{maximum: maximum, exclusive_maximum: exclusive_maximum},
    number
  ), do: maximum(maximum, exclusive_maximum, number)

  @spec multiple_of(Xema.keywords, number) :: :ok | {:error, map}
  def multiple_of(%{multiple_of: nil} = _keywords, _number), do: :ok
  def multiple_of(%{multiple_of: multiple_of}, number) do
    x = number / multiple_of
    if x - Float.floor(x) == 0,
      do: :ok,
      else: error :not_multiple, multiple_of: multiple_of
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
