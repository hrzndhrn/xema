defmodule Xema.Mapz do
  @moduledoc false

  import Xema.Utils, only: [to_existing_atom: 1]

  @spec get(map, String.t() | atom) :: any
  def get(map, key) do
    map
    |> fetch(key)
    |> case do
      {:ok, val} -> val
      _ -> nil
    end
  end

  @spec fetch(map, String.t() | atom) :: any
  def fetch(map, key) when is_map(map) and is_atom(key) do
    do_fetch(map, to_string(key), key)
  end

  def fetch(map, key) when is_map(map) do
    do_fetch(map, key, to_existing_atom(key))
  end

  defp do_fetch(map, key_string, key_atom) do
    case {Map.fetch(map, key_string), Map.fetch(map, key_atom)} do
      {:error, :error} ->
        :error

      {:error, {:ok, _} = value} ->
        value

      {{:ok, _} = value, :error} ->
        value

      _ ->
        {:error, :mixed_map}
    end
  end


  @spec delete(map, String.t() | atom) :: map
  def delete(map, prop) when is_map(map) and is_atom(prop) do
    case Map.has_key?(map, prop) do
      true -> Map.delete(map, prop)
      false -> Map.delete(map, Atom.to_string(prop))
    end
  end

  def delete(map, prop) when is_map(map) and is_binary(prop) do
    case Map.has_key?(map, prop) do
      true -> Map.delete(map, prop)
      false -> Map.delete(map, to_existing_atom(prop))
    end
  end

  @spec get_key(map, String.t() | atom) :: atom | String.t()
  def get_key(map, key) when is_map(map) and is_atom(key) do
    if Map.has_key?(map, key), do: key, else: to_string(key)
  end

  def get_key(map, key) when is_map(map) do
    if Map.has_key?(map, key), do: key, else: to_existing_atom(key)
  end

  @spec has_key?(map | [{term(), term()}], String.t() | atom) :: boolean
  def has_key?(map, key) when is_map(map),
    do: Map.has_key?(map, key) || Map.has_key?(map, toggle_key(key))

  def has_key?(list, key) when is_list(list) do
    Enum.any?(list, fn {k, _} -> k == key end)
  end

  @spec toggle_key(String.t() | atom) :: atom | String.t()
  def toggle_key(key) when is_binary(key), do: to_existing_atom(key)

  def toggle_key(key) when is_atom(key), do: Atom.to_string(key)

  @spec intersection(map, map) :: map
  def intersection(a, b) when is_map(a) and is_map(b),
    do:
      for(
        key <- Map.keys(a),
        true == Map.has_key?(b, key),
        into: %{},
        do: {key, Map.get(b, key)}
      )
end
