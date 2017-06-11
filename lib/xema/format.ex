defmodule Xema.Format do
  @moduledoc """
  TODO
  """

  @formats %{
    email: ~r/.+@.*\..+/
  }

  @spec match?(atom, String.t) :: boolean
  def match?(format, string), do: Regex.match?(@formats[format], string)

  @spec member?(atom) :: boolean
  def member?(format), do: Map.has_key?(@formats, format)
end
