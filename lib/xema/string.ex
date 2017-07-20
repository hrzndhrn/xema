defmodule Xema.String do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  use Xema.Validator.Enum

  import Xema.Helper.Error

  alias Xema.Validator.Format

  defstruct [
    :max_length,
    :min_length,
    :pattern,
    :format,
    :enum,
    as: :string
  ]

  @spec keywords(list) :: %Xema{}
  def keywords([]), do: %Xema.String{}
  def keywords(keywords), do: struct(Xema.String, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(xema, string), do: validate(xema, string) == :ok

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
  def validate(%Xema{keywords: keywords}, string) do
    with :ok <- type(keywords, string),
         length <- String.length(string),
         :ok <- min_length(keywords.min_length, length),
         :ok <- max_length(keywords.max_length, length),
         :ok <- pattern(keywords.pattern, string),
         :ok <- format(keywords.format, string),
         :ok <- enum(keywords, string),
      do: :ok
  end

  defp type(_keywords, string) when is_binary(string), do: :ok

  defp type(keywords, _string), do: error(:wrong_type, type: keywords.as)

  defp min_length(nil, _length), do: :ok

  defp min_length(min_length, length),
    do: if length >= min_length,
          do: :ok,
          else: error(:too_short, min_length: min_length)

  defp max_length(nil, _length), do: :ok

  defp max_length(max_length, length),
    do: if length <= max_length,
          do: :ok,
          else: error(:too_long, max_length: max_length)

  defp pattern(nil, _string), do: :ok

  defp pattern(pattern, string),
    do: if Regex.match?(pattern, string),
          do: :ok,
          else: error(:no_match, pattern: pattern)

  defp format(nil, _string), do: :ok

  defp format(format, string), do: Format.validate(format, string)
end
