defmodule Xema.NoResolver do
  @moduledoc """
  The default resolver.
  """

  @behaviour Xema.Resolver

  @doc """
  Returns always the error tuple `{:error, "No resolver configured."}`.
  """
  @spec get(binary) :: {:error, binary}
  def get(_), do: {:error, "No resolver configured."}
end
