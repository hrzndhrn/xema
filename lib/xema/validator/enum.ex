defmodule Xema.Validator.Enum do
  @moduledoc """
  TODO
  """

  import Xema.Helper.Error

  @spec enum(struct(), any()) :: :ok | {:error, map()}
  def enum(%{enum: nil}, _value), do: :ok
  def enum(%{enum: enum}, value) do
    if Enum.member?(enum, value),
      do: :ok,
      else: error(:not_in_enum, enum: enum)
  end
end
