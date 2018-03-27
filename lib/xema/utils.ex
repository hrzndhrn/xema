defmodule Xema.Utils do
  @spec get_value(map, String.t() | atom) :: any
  def get_value(map, key) when is_atom(key) do
    do_get_value(map, to_string(key), key)
  end

  def get_value(map, key) do
    do_get_value(map, key, String.to_atom(key))
  end

  defp do_get_value(map, key_string, key_atom) do
    case {Map.get(map, key_string), Map.get(map, key_atom)} do
      {nil, nil} ->
        {:ok, nil}

      {nil, value} ->
        {:ok, value}

      {value, nil} ->
        {:ok, value}

      _ ->
        {:error, :mixed_map}
    end
  end
end
