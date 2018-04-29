defmodule Xema.Resolver do
  @moduledoc """
  The behaviour for resolvers.
  """

  @type exon :: atom | tuple | list | map
  @type reason :: any

  @callback get(uri :: String.t()) :: {:ok, exon} | {:error, reason}
end
