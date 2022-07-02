defmodule Xema.Utils do
  @moduledoc """
  Some utilities for Xema.
  """

  @doc """
  Converts the given `string` to an existing atom. Returns `nil` if the
  atom does not exist.

  ## Examples

        iex> import Xema.Utils
        iex> to_existing_atom(:my_atom)
        :my_atom
        iex> to_existing_atom("my_atom")
        :my_atom
        iex> to_existing_atom("not_existing_atom")
        nil
  """
  @spec to_existing_atom(String.t() | atom) :: atom | nil
  def to_existing_atom(atom) when is_atom(atom), do: atom

  def to_existing_atom(string) when is_binary(string) do
    String.to_existing_atom(string)
  rescue
    _ -> nil
  end

  @doc """
  Returns whether the given `key` exists in the given `value`.

  Returns true if
  * `value` is a map and contains `key` as a key.
  * `value` is a keyword and contains `key` as a key.
  * `value` is a list of tuples with `key`as the first element.

  ## Examples
        iex> alias Xema.Utils
        iex> Utils.has_key?(%{foo: 5}, :foo)
        true
        iex> Utils.has_key?([foo: 5], :foo)
        true
        iex> Utils.has_key?([{"foo", 5}], "foo")
        true
        iex> Utils.has_key?([{"foo", 5}], "bar")
        false
        iex> Utils.has_key?([], "bar")
        false
  """
  @spec has_key?(map | keyword | [{String.t(), any}], any) :: boolean
  def has_key?([], _), do: false

  def has_key?(value, key) when is_map(value), do: Map.has_key?(value, key)

  def has_key?(value, key) when is_list(value) do
    case Keyword.keyword?(value) do
      true -> Keyword.has_key?(value, key)
      false -> Enum.any?(value, fn {k, _} -> k == key end)
    end
  end

  @doc """
  Returns `nil` if `uri_1` and `uri_2` are `nil`.
  Parses a URI when the other URI is `nil`.
  Merges URIs if both are not nil.
  """
  @spec update_uri(URI.t() | String.t() | nil, URI.t() | String.t() | nil) ::
          URI.t() | nil
  def update_uri(nil, nil), do: nil

  def update_uri(uri_1, nil), do: URI.parse(uri_1)

  def update_uri(nil, uri_2), do: URI.parse(uri_2)

  def update_uri(uri_1, uri_2), do: URI.merge(uri_1, uri_2)

  @doc """
  Returns the size of a `list` or `tuple`.
  """
  @spec size(list | tuple) :: integer
  def size(list) when is_list(list), do: length(list)

  def size(tuple) when is_tuple(tuple), do: tuple_size(tuple)

  @doc """
  Converts a `map` with integer keys or integer keys represented as strings to
  a sorted list.

  Returns an ok tuple with the list or an `:error` atom.

  ## Options:
    * `keys` - if `true` the resulting list has `{key, value}` items, with false
               the list contains the values. Defaults to `[keys: true]`.

  ## Examples

        iex> alias Xema.Utils
        iex> Utils.to_sorted_list(%{2 => "b", 3 => "c", 1 => "a"})
        {:ok, [{1, "a"}, {2, "b"}, {3, "c"}]}
        iex> Utils.to_sorted_list(%{"2" => "b", "3" => "c", "1" => "a"})
        {:ok, [{"1", "a"}, {"2", "b"}, {"3", "c"}]}
        iex> Utils.to_sorted_list(%{"2" => "b", "x" => "c", "1" => "a"})
        :error
        iex> Utils.to_sorted_list(%{"2" => "b", "3" => "c", "1" => "a"}, keys: true)
        {:ok, [{"1", "a"}, {"2", "b"}, {"3", "c"}]}
        iex> Utils.to_sorted_list(%{"2" => "b", "3" => "c", "1" => "a"}, keys: false)
        {:ok, ["a", "b", "c"]}

  """
  @spec to_sorted_list(map(), keys: boolean()) :: {:ok, list()} | :error
  def to_sorted_list(map, opts \\ [keys: true]) do
    result =
      Enum.reduce_while(map, [], fn {key, _value} = item, acc ->
        case to_integer(key) do
          {:ok, integer} -> {:cont, [{integer, item(item, opts)} | acc]}
          :error -> {:halt, nil}
        end
      end)

    case result do
      nil ->
        :error

      list ->
        list =
          list
          |> Enum.sort_by(fn {index, _value} -> index end)
          |> Enum.map(fn {_index, value} -> value end)

        {:ok, list}
    end
  end

  defp item(item, keys: true), do: item

  defp item({_key, value}, keys: false), do: value

  defp to_integer(value) when is_integer(value), do: {:ok, value}

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {integer, ""} -> {:ok, integer}
      _error -> :error
    end
  end

  defp to_integer(_value), do: :error
end
