defprotocol Xema.Castable do
  @moduledoc """
  Converts data using the specified schema.
  """

  @doc """
  Converts the given data using the specified schema.
  """
  def cast(value, schema)
end

defimpl Xema.Castable, for: Atom do
  alias Xema.Schema

  def cast(atom, %Schema{type: :any}), do: {:ok, atom}

  def cast(atom, %Schema{type: :atom}), do: {:ok, atom}

  def cast(atom, %Schema{type: :string}), do: {:ok, to_string(atom)}

  def cast(atom, %Schema{type: type}),
    do: {:error, %{to: type, cast: Atom, value: atom}}
end

defimpl Xema.Castable, for: BitString do
  import Xema.Utils, only: [to_existing_atom: 1]

  alias Xema.Schema

  def cast(str, %Schema{type: :any}), do: {:ok, str}

  def cast(str, %Schema{type: :atom}) do
    case to_existing_atom(str) do
      nil -> {:error, {:unknown_atom, str}}
      atom -> {:ok, atom}
    end
  end

  def cast(str, %Schema{type: :float}) do
    to_float(str)
  end

  def cast(str, %Schema{type: :integer}) do
    to_integer(str)
  end

  def cast(str, %Schema{type: :number}) do
    case String.contains?(str, ".") do
      true -> to_float(str)
      false -> to_integer(str)
    end
  end

  def cast(str, %Schema{type: :string}), do: {:ok, str}

  def cast(str, %Schema{type: type}),
    do: {:error, %{to: type, cast: BitString, value: str}}

  defp to_integer(str) do
    case Integer.parse(str) do
      {int, ""} -> {:ok, int}
      _ -> {:error, {:not_an_integer, str}}
    end
  end

  defp to_float(str) do
    case Float.parse(str) do
      {int, ""} -> {:ok, int}
      _ -> {:error, {:not_a_float, str}}
    end
  end
end

defimpl Xema.Castable, for: Float do
  alias Xema.Schema

  def cast(float, %Schema{type: :any}), do: {:ok, float}

  def cast(float, %Schema{type: :float}), do: {:ok, float}

  def cast(float, %Schema{type: :number}), do: {:ok, float}

  def cast(float, %Schema{type: :string}), do: {:ok, to_string(float)}

  def cast(float, %Schema{type: type}),
    do: {:error, %{to: type, cast: Float, value: float}}
end

defimpl Xema.Castable, for: Integer do
  alias Xema.Schema

  def cast(int, %Schema{type: :any}), do: {:ok, int}

  def cast(int, %Schema{type: :integer}), do: {:ok, int}

  def cast(int, %Schema{type: :number}), do: {:ok, int}

  def cast(int, %Schema{type: :string}), do: {:ok, to_string(int)}

  def cast(int, %Schema{type: type}),
    do: {:error, %{to: type, cast: Integer, value: int}}
end

defimpl Xema.Castable, for: List do
  alias Xema.Schema

  def cast(list, %Schema{type: :any}), do: {:ok, list}

  def cast(list, %Schema{type: :list}), do: {:ok, list}

  def cast(list, %Schema{type: type}) do
    case Keyword.keyword?(list) do
      true -> {:error, %{to: type, cast: Keyword, value: list}}
      false -> {:error, %{to: type, cast: List, value: list}}
    end
  end
end

defimpl Xema.Castable, for: Map do
  import Xema.Utils, only: [to_existing_atom: 1]

  alias Xema.Schema

  def cast(map, %Schema{type: :any}), do: {:ok, map}

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

  def cast(map, %Schema{type: type}),
    do: {:error, %{to: type, cast: Map, value: map}}

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
