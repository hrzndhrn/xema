defmodule Xema.Error do
  @moduledoc """
  TODO
  """

  @spec error(atom, keyword) :: {:error, map}
  def error(reason, info \\ []) do
    info =
      info
      |> Enum.into(%{})
      |> Map.merge(%{reason: reason})

    {:error, info}
  end
end
