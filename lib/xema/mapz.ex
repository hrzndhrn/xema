defmodule Xema.Mapz do
  @moduledoc """
  A set of functions for working with maps.

  This functions are working a little bit different as the function of the
  coure `Map` module.
  """

  import Xema.Utils, only: [to_existing_atom: 1]

  @compile {:inline,
            get: 2,
            fetch: 2,
            do_fetch: 3,
            delete: 2,
            get_key: 2,
            has_key?: 2,
            toggle_key: 1,
            intersection: 2,
            map_values: 2}

  @typedoc """
  The `key` of a map.
  """
  @type key :: any

  @typedoc """
  The `value` of a map.
  """
  @type value :: any

  @doc """
  Gets the value for a specific `key` in `map`. The function will toggle the
  `key` to get a value from an atom key or an string key.

  ## Examples

      iex> map = Map.merge(%{a: 1}, %{"b" => 2})
      iex> Xema.Mapz.get(map, :a)
      1
      iex> Xema.Mapz.get(map, "a")
      1
      iex> Xema.Mapz.get(map, :b)
      2
      iex> Xema.Mapz.get(map, "b")
      2
      iex> Xema.Mapz.get(map, :c)
      nil
  """
  @spec get(map, key) :: value
  def get(map, key) do
    map
    |> fetch(key)
    |> case do
      {:ok, val} ->
        val

      {:error, :mixed_map} ->
        raise "Map contains same key as string and atom (key: #{inspect(key)})."

      _ ->
        nil
    end
  end

  @doc """
  Fetches the value for a `key`in the given `map`. The function will toggle the
  `key` to get a value from an atom key or an string key.

  If `map` contains the given `key` with value value, then `{:ok, value}` is
  returned.
  If `map` doesn't contain `key`, `:error` is returned.
  If `map` contains the `key` as string key and atom key, then
  `{:error, :mixed_map}` is returned.

  ## Examples

      iex> Mapz.fetch(%{a: 1}, :a)
      {:ok, 1}
      iex> Mapz.fetch(%{a: 1}, :b)
      :error
      iex> Mapz.fetch(%{:a => 1, "a" => 2}, :a)
      {:error, :mixed_map}
  """
  @spec fetch(map, key) :: any
  def fetch(map, key) when is_map(map) and is_atom(key),
    do: do_fetch(map, to_string(key), key)

  def fetch(map, key) when is_map(map),
    do: do_fetch(map, key, to_existing_atom(key))

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

  @doc """
  Deletes the entry in `map` for a `key`. The function will toggle the
  `key` to delet an entry.

  If the `key` does not exist, returns `map` unchanged.

  ## Examples

      iex> Xema.Mapz.delete(%{a: 1, b: 2}, "a")
      %{b: 2}
      iex> Xema.Mapz.delete(%{"a" => 1, "b" => 2}, :a)
      %{"b" => 2}
  """
  @spec delete(map, key) :: map
  def delete(map, key) when is_map(map) and is_atom(key) do
    case Map.has_key?(map, key) do
      true -> Map.delete(map, key)
      false -> Map.delete(map, Atom.to_string(key))
    end
  end

  def delete(map, key) when is_map(map) and is_binary(key) do
    case Map.has_key?(map, key) do
      true -> Map.delete(map, key)
      false -> Map.delete(map, to_existing_atom(key))
    end
  end

  @doc """
  Returns the `key` of the given `map` as atom or string, regarding to the key
  in the `map`.

  ## Examples

      iex> Xema.Mapz.get_key(%{a: 1}, "a")
      :a
      iex> Xema.Mapz.get_key(%{"a" => 1}, :a)
      "a"
      iex> Xema.Mapz.get_key(%{a: 1}, "b")
      nil
  """
  @spec get_key(map, key) :: key
  def get_key(map, key) when is_map(map) and is_atom(key) do
    do_get_key(map, key, &to_string/1)
  end

  def get_key(map, key) when is_map(map) and is_binary(key) do
    do_get_key(map, key, &to_existing_atom/1)
  end

  defp do_get_key(map, key, fun) do
    case Map.has_key?(map, key) do
      true ->
        key

      false ->
        key = fun.(key)

        case Map.has_key?(map, key) do
          true -> key
          false -> nil
        end
    end
  end

  @doc """
  Returns whether the given `key` exists as string key or atom key in the given
  `map`.

  ## Examples

      iex> Xema.Mapz.has_key?(%{a: 1}, :a)
      true
      iex> Xema.Mapz.has_key?(%{a: 1}, "a")
      true
      iex> Xema.Mapz.has_key?(%{a: 1}, :b)
      false
  """
  @spec has_key?(map, key) :: boolean
  def has_key?(map, key) when is_map(map),
    do: Map.has_key?(map, key) || Map.has_key?(map, toggle_key(key))

  @spec toggle_key(String.t() | atom) :: atom | String.t()
  defp toggle_key(key) when is_binary(key), do: to_existing_atom(key)

  defp toggle_key(key) when is_atom(key), do: to_string(key)

  @doc """
  Returns a map containing only keys that `map_1` and `map_2` have in common.
  Values for the returned map are taken from `map_2`.

  ## Examples

      iex> Xema.Mapz.intersection(%{a: 1, b: 2}, %{b: 3, c: 4})
      %{b: 3}
  """
  @spec intersection(map, map) :: map
  def intersection(map_1, map_2) when is_map(map_1) and is_map(map_2),
    do:
      for(
        key <- Map.keys(map_1),
        true == Map.has_key?(map_2, key),
        into: %{},
        do: {key, Map.get(map_2, key)}
      )

  @doc """
  Returns a map where each value is the result of invokiing
  `fun` on each value of the given `map`.

  ## Examples

      iex> Xema.Mapz.map_values(%{a: 1, b: 2, c: 3}, fn x -> x * 2 end)
      %{a: 2, b: 4, c: 6}
  """
  @spec map_values(map, (value -> value)) :: map
  def map_values(map, fun)
      when is_map(map) and is_function(fun),
      do: Enum.into(map, %{}, fn {key, val} -> {key, fun.(val)} end)
end
