defmodule Xema.Format do
  @moduledoc """
  TODO
  """

  @formats %{
    email: ~r/.+@.*\..+/
  }

  def match?(format, string), do: Regex.match?(@formats[format], string)

  def member?(format), do: Map.has_key?(@fromats, format)
end
