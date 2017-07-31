defmodule Xema.String do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  import Xema.Helper.Error
  import Xema.Validator.Enum

  alias Xema.Validator.Format

  defstruct [
    :max_length,
    :min_length,
    :pattern,
    :format,
    :enum,
    as: :string
  ]

  @spec new(list) :: %Xema{}
  def new([]), do: %Xema.String{}
  def new(keywords), do: struct(Xema.String, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(xema, string), do: validate(xema, string) == :ok

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
  def validate(%Xema{keywords: keywords}, string) do
    with :ok <- type(keywords, string),
         length <- String.length(string),
         :ok <- min_length(keywords, length),
         :ok <- max_length(keywords, length),
         :ok <- pattern(keywords, string),
         :ok <- format(keywords, string),
         :ok <- enum(keywords, string),
      do: :ok
  end

  defp type(_keywords, string) when is_binary(string), do: :ok
  defp type(keywords, _string), do: error(:wrong_type, type: keywords.as)

  defp min_length(%Xema.String{min_length: nil}, _length), do: :ok
  defp min_length(%Xema.String{min_length: min_length}, length) do
    if length >= min_length do
      :ok
    else
      error(:too_short, min_length: min_length)
    end
  end

  defp max_length(%Xema.String{max_length: nil}, _length), do: :ok
  defp max_length(%Xema.String{max_length: max_length}, length) do
    if length <= max_length do
      :ok
    else
      error(:too_long, max_length: max_length)
    end
  end

  defp pattern(%Xema.String{pattern: nil}, _string), do: :ok
  defp pattern(%Xema.String{pattern: pattern}, string) do
    if Regex.match?(pattern, string) do
      :ok
    else
      error(:no_match, pattern: pattern)
    end
  end

  defp format(%Xema.String{format: nil}, _string), do: :ok
  defp format(%Xema.String{format: format}, string), do: Format.validate(format, string)
end
