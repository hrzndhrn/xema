defmodule Xema.String do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct max_length: nil,
            min_length: nil,
            pattern: nil

  def properties([]), do: %Xema.String{}

  def properties(properties), do: struct(Xema.String, properties)

  def is_valid?(properties, string), do: validate(properties, string) == :ok

  def validate(properties, string) do
    with :ok <- type?(string),
         length <- String.length(string),
         :ok <- min_length?(properties.min_length, length),
         :ok <- max_length?(properties.max_length, length),
         :ok <- pattern?(properties.pattern, string),
      do: :ok
  end

  defp type?(string) when is_binary(string), do: :ok

  defp type?(_string), do: {:error, {:type, :string}}

  defp min_length?(nil, _length), do: :ok

  defp min_length?(min_length, length),
    do: if length >= min_length,
          do: :ok,
          else: {:error, {:min_length, min_length}}

  defp max_length?(nil, _length), do: :ok

  defp max_length?(max_length, length),
    do: if length <= max_length,
          do: :ok,
          else: {:error, {:max_length, max_length}}

  defp pattern?(nil, _string), do: :ok

  defp pattern?(pattern, string),
    do: if Regex.match?(pattern, string),
          do: :ok,
          else: {:error, {:pattern, pattern}}
end
