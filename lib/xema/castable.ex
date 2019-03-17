defprotocol Xema.Castable do
  @moduledoc """
  TODO
  """

  @doc """
  TODO
  """
  def cast(value, schema)
end

defimpl Xema.Castable, for: Map do
  import Xema.Utils, only: [to_existing_atom: 1]

  alias Xema.Schema

  def cast(map, %Schema{type: :map, keys: keys}) do
    Enum.reduce_while(map, {:ok, %{}}, fn {key, value}, {:ok, acc} ->
      case cast_key(key, keys) do
        {:ok, key} ->
          {:cont, {:ok, Map.put(acc, key, value)}}

        :error ->
          {:halt, {:error, {:unknown_atom, key}}}
      end
    end)
  end

  def cast(map, %Schema{type: :any}), do: {:ok, map}

  def cast(_, %Schema{type: type}),
    do: {:error, %{to: type, cast: Map}}

  defp cast_key(value, :atoms) when is_binary(value) do
    case to_existing_atom(value) do
      nil -> :error
      cast -> {:ok, cast}
    end
  end

  defp cast_key(value, :strings) when is_atom(value),
    do: {:ok, Atom.to_string(value)}

  defp cast_key(value, _), do: {:ok, value}
end

defimpl Xema.Castable, for: BitString do
  alias Xema.Schema

  def cast(str, %Schema{type: :string}), do: {:ok, str}

  def cast(str, %Schema{type: :integer}) do
    case Integer.parse(str) do
      {int, ""} -> {:ok, int}
      _ -> {:error, :not_an_integer}
    end
  end

  def cast(str, %Schema{type: :any}), do: {:ok, str}

  def cast(_, %Schema{type: type}),
    do: {:error, %{to: type, cast: BitString}}
end

defimpl Xema.Castable, for: Integer do
  alias Xema.Schema

  def cast(int, %Schema{type: :integer}), do: {:ok, int}

  def cast(int, %Schema{type: :string}), do: {:ok, to_string(int)}

  def cast(int, %Schema{type: :any}), do: {:ok, int}

  def cast(_, %Schema{type: type}),
    do: {:error, %{to: type, cast: Integer}}
end
