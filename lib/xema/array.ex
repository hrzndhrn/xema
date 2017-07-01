defmodule Xema.Array do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct items: nil,
            min_items: nil,
            max_items: nil

  alias Xema.Array

  @spec properties(list) :: %Array{}
  def properties(properties), do: struct(%Xema.Array{}, properties)

  @spec is_valid?(%Array{}, any) :: boolean
  def is_valid?(properties, list), do: validate(properties, list) == :ok

  @spec validate(%Array{}, any) :: :ok | {:error, any}
  def validate(properties, list) do
    with :ok <- type(list),
         :ok <- min_items(properties, list),
         :ok <- max_items(properties, list),
         :ok <- items(properties, list),
      do: :ok
  end

  defp type(list) when is_list(list), do: :ok
  defp type(_), do: {:error, %{type: :array}}

  defp min_items(%Array{min_items: nil}, _list), do: :ok
  defp min_items(%Array{min_items: min_items}, list)
    when length(list) < min_items,
    do: {:error, %{min_items: min_items}}
  defp min_items(_properties, _list), do: :ok

  defp max_items(%Array{max_items: nil}, _list), do: :ok
  defp max_items(%Array{max_items: max_items}, list)
    when length(list) > max_items,
    do: {:error, %{max_items: max_items}}
  defp max_items(_properties, _list), do: :ok

  defp items(%Array{items: nil}, _list), do: :ok
  defp items(%Array{items: items}, list)
    when is_list(items),
    do: items_tuple(items, list, 0)
  defp items(%Array{items: items}, list) do
    items_list(items, list, 0)
  end

  defp items_list(_schema, [], _at), do: :ok
  defp items_list(schema, [item|list], at) do
    case Xema.validate(schema, item) do
      :ok -> items_list(schema, list, at + 1)
      error -> {:error, :nested, %{at: at, error: error}}
    end
  end

  defp items_tuple([], [], _at), do: :ok
  defp items_tuple(_, [], at), do: {:error, :missing_value, %{at: at}}
  defp items_tuple([], _, at), do: {:error, :extra_value, %{at: at}}
  defp items_tuple([schema|schemas], [item|list], at) do
    case Xema.validate(schema, item) do
      :ok -> items_tuple(schemas, list, at + 1)
      error -> {:error, :nested, %{at: at, error: error}}
    end
  end
end
