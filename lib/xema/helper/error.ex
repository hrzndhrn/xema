defmodule Xema.Helper.Error do
  @moduledoc false

  @spec error(atom, keyword) :: {:error, map}
  def error(reason, info \\ []) do
    info =
      info
      |> Enum.into(%{})
      |> Map.merge(%{reason: reason})

    {:error, info}
  end
end
