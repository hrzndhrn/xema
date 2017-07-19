defmodule Xema.Validator.Enum do
  @moduledoc """
  TODO
  """

  import Xema.Helper.Error

  defmacro __using__(_) do
    quote do
      defp enum(%{enum: nil}, _value), do: :ok
      defp enum(%{enum: enum}, value) do
        if Enum.member?(enum, value),
          do: :ok,
          else: error(:not_in_enum, enum: enum)
      end
    end
  end
end
