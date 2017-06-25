defmodule Xema.Enum do
  @moduledoc """
  TODO
  """

  defstruct list: []

  @behaviour Xema

  @spec properties(list) :: nil
  def properties(list), do: %Xema.Enum{list: list}

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(%Xema.Enum{list: list}, item), do: Enum.member?(list, item)

  @spec validate(%Xema{}, any) :: :ok | {:error, any}
  def validate(%Xema.Enum{list: list}, item) do
    if Enum.member?(list, item),
      do: :ok,
      else: {:error, %{enum: list}}
  end

  defmacro __using__(_) do
    quote do
      defp enum?(%{enum: nil}, _value), do: :ok
      defp enum?(%{enum: enum}, value),
        do: Xema.validate(enum, value)
    end
  end
end
