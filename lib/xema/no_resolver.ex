defmodule Xema.NoResolver do
  @moduledoc """
  The default resolver. For the resolver configuration see
  "[Configure a resolver](resolver.html)".
  """

  @behaviour Xema.Resolver

  @doc """
  Returns always the error tuple `{:error, "No resolver configured."}`.
  """
  @spec fetch(any) :: {:error, binary}
  def fetch(_), do: {:error, "No resolver configured."}
end
