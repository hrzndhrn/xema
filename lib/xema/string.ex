defmodule Xema.String do
  @moduledoc """
  TODO
  """

  alias Xema.Format

  @behaviour Xema

  defstruct max_length: nil,
            min_length: nil,
            pattern: nil,
            format: nil

  @spec keywords(list) :: %Xema{}
  def keywords([]), do: %Xema.String{}
  def keywords(keywords), do: struct(Xema.String, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(keywords, string), do: validate(keywords, string) == :ok

  @spec validate(%Xema{}, any) :: :ok | {:error, any}
  def validate(keywords, string) do
    with :ok <- type(string),
         length <- String.length(string),
         :ok <- min_length(keywords.min_length, length),
         :ok <- max_length(keywords.max_length, length),
         :ok <- pattern(keywords.pattern, string),
         :ok <- format(keywords.format, string),
      do: :ok
  end

  defp type(string) when is_binary(string), do: :ok

  defp type(_string), do: {:error, :wrong_type, %{type: :string}}

  defp min_length(nil, _length), do: :ok

  defp min_length(min_length, length),
    do: if length >= min_length,
          do: :ok,
          else: {:error, %{min_length: min_length}}

  defp max_length(nil, _length), do: :ok

  defp max_length(max_length, length),
    do: if length <= max_length,
          do: :ok,
          else: {:error, %{max_length: max_length}}

  defp pattern(nil, _string), do: :ok

  defp pattern(pattern, string),
    do: if Regex.match?(pattern, string),
          do: :ok,
          else: {:error, %{pattern: pattern}}

  defp format(nil, _string), do: :ok

  defp format(format, string), do: Format.validate(format, string)
end
