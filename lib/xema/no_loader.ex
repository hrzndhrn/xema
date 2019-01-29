defmodule Xema.NoLoader do
  @moduledoc """
  The default loader. For the loader configuration see
  "[Configure a loader](loader.html)".
  """

  @behaviour Xema.Loader

  @doc """
  Returns always the error tuple `{:error, "No loader configured."}`.
  """
  @spec fetch(any) :: {:error, binary}
  def fetch(_), do: {:error, "No loader configured."}
end
