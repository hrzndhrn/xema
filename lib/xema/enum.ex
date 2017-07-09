defmodule Xema.Enum do
  @moduledoc """
  TODO
  """

  import Xema.Error

  @behaviour Xema

  defstruct list: []

  defmacro __using__(_) do
    quote do
      defp enum(%__module__{enum: nil}, _value), do: :ok
      defp enum(%__module__{enum: enum}, value),
        do: Xema.validate(enum, value)
    end
  end

  @spec keywords(keyword) :: %Xema{}
  def keywords(list), do: %Xema.Enum{list: list}

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(enum, item),
    do: Enum.member?(enum.list, item)

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
  def validate(enum, item) do
    if Enum.member?(enum.list, item),
      do: :ok,
      else: error(:not_in_enum, enum: enum.list)
  end
end
