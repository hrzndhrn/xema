defmodule Xema.Caster do
  @moduledoc """
  A behaviour for a caster.
  """

  @doc """
  A callback for a caster.
  """
  @callback cast(term) :: {:ok, term} | :error
end
