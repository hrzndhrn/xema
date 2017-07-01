defmodule Xema.Enum do
  @moduledoc """
  TODO
  """

  defmacro __using__(_) do
    quote do
      defp enum(%{enum: nil}, _value), do: :ok
      defp enum(%{enum: enum}, value),
        do: Xema.validate(enum, value)
    end
  end

  defstruct list: []

  @behaviour Xema

  @spec keywords(list) :: nil
  def keywords(list), do: %Xema.Enum{list: list}

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(%Xema.Enum{list: list}, item), do: Enum.member?(list, item)

  @spec validate(%Xema{}, any) :: :ok | {:error, any}
  def validate(%Xema.Enum{list: list}, item) do
    if Enum.member?(list, item),
      do: :ok,
      else: {:error, :not_in_enum, %{enum: list}}
  end
end
