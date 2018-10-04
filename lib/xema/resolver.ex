defmodule Xema.Resolver do
  @moduledoc """
  The behaviour for resolvers.
  """

  @callback fetch(uri :: binary) :: {:ok, any} | {:error, any}
end
