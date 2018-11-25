defmodule Xema.NoResolver do
  @moduledoc """
  The default resolver.
  """

  @behaviour Xema.Resolver

  @doc """
  Returns always the error tuple `{:error, "No resolver configured."}`.
  """
  @spec fetch(any) :: {:error, binary}
  def fetch(_), do: {:error, "No resolver configured."}
end
