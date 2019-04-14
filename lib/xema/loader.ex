defmodule Xema.Loader do
  @moduledoc """
  The behaviour for loaders.

  For the loader configuration see "[Configure a loader](loader.html)".
  """

  @doc """
  This function expected an URI, to fetch the required data to create a schema.
  """
  @callback fetch(uri :: URI.t()) :: {:ok, any} | {:error, any}

  defp impl, do: Application.get_env(:xema, :loader)

  def fetch(uri), do: impl().fetch(uri)
end
