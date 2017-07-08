defmodule Xema.Error do

  def error(reason, info \\ []) do
    info =
      info
      |> Enum.into(%{})
      |> Map.merge(%{reason: reason})

    {:error, info}
  end
end
