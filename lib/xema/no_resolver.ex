defmodule Xema.NoResolver do
  @moduledoc """
  The default resolver.
  """

  @behaviour Xema.Resolver

  @doc """
  Returns always the error tuple `{:error, "No resolver configured."}`.
  """
  def get(_), do: {:error, "No resolver configured."}
end
