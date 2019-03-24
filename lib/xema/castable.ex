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

  def cast(atom, %Schema{type: boolean}) when is_boolean(boolean), do: {:ok, atom}

  def cast(nil, %Schema{type: nil}), do: {:ok, nil}

  def cast(atom, %Schema{type: :atom}), do: {:ok, atom}

  def cast(atom, %Schema{type: :string}), do: {:ok, to_string(atom)}

  def cast(atom, %Schema{type: :boolean}) when is_boolean(atom), do: {:ok, atom}

  def cast(atom, %Schema{type: type}),
    do: {:error, %{to: type, value: atom}}
end

defimpl Xema.Castable, for: BitString do
  import Xema.Utils, only: [to_existing_atom: 1]

  alias Xema.Schema

  def cast(str, %Schema{type: :any}), do: {:ok, str}

  def cast(str, %Schema{type: boolean}) when is_boolean(boolean), do: {:ok, str}

  def cast(str, %Schema{type: :atom}) do
    case to_existing_atom(str) do
      nil -> {:error, %{to: :atom, value: str}}
      atom -> {:ok, atom}
    end
  end

  def cast(str, %Schema{type: :float}), do: to_float(str, :float)

  def cast(str, %Schema{type: :integer}), do: to_integer(str, :integer)

  def cast(str, %Schema{type: :number}) do
    case String.contains?(str, ".") do
      true -> to_float(str, :number)
      false -> to_integer(str, :number)
    end
  end

  def cast(str, %Schema{type: :string}), do: {:ok, str}

  def cast(str, %Schema{type: type}), do: {:error, %{to: type, value: str}}

  defp to_integer(str, type) when type in [:integer, :number] do
    case Integer.parse(str) do
      {int, ""} -> {:ok, int}
      _ -> {:error, %{to: type, value: str}}
    end
  end

  defp to_float(str, type) when type in [:float, :number] do
    case Float.parse(str) do
      {int, ""} -> {:ok, int}
      _ -> {:error, %{to: type, value: str}}
    end
  end
end

defimpl Xema.Castable, for: Float do
  alias Xema.Schema

  def cast(float, %Schema{type: :any}), do: {:ok, float}

  def cast(float, %Schema{type: boolean}) when is_boolean(boolean), do: {:ok, float}

  def cast(float, %Schema{type: :float}), do: {:ok, float}

  def cast(float, %Schema{type: :number}), do: {:ok, float}

  def cast(float, %Schema{type: :string}), do: {:ok, to_string(float)}

  def cast(float, %Schema{type: type}),
    do: {:error, %{to: type, value: float}}
end

defimpl Xema.Castable, for: Integer do
  alias Xema.Schema

  def cast(int, %Schema{type: :any}), do: {:ok, int}

  def cast(int, %Schema{type: boolean}) when is_boolean(boolean), do: {:ok, int}

  def cast(int, %Schema{type: :integer}), do: {:ok, int}

  def cast(int, %Schema{type: :number}), do: {:ok, int}

  def cast(int, %Schema{type: :string}), do: {:ok, to_string(int)}

  def cast(int, %Schema{type: type}),
    do: {:error, %{to: type, value: int}}
end

defimpl Xema.Castable, for: List do
  alias Xema.Schema

  def cast(list, %Schema{type: :any}), do: {:ok, list}

  def cast(list, %Schema{type: boolean}) when is_boolean(boolean), do: {:ok, list}

  def cast(list, %Schema{type: :list}), do: {:ok, list}

  def cast(list, %Schema{type: type}), do: {:error, %{to: type, value: list}}
end

defimpl Xema.Castable, for: Map do
  import Xema.Utils, only: [to_existing_atom: 1]

  alias Xema.Schema

  def cast(map, %Schema{type: :any}), do: {:ok, map}

  def cast(map, %Schema{type: boolean}) when is_boolean(boolean), do: {:ok, map}

  def cast(map, %Schema{type: :map, keys: keys}) do
    Enum.reduce_while(map, {:ok, %{}}, fn {key, value}, {:ok, acc} ->
      case cast_key(key, keys) do
        {:ok, key} ->
          {:cont, {:ok, Map.put(acc, key, value)}}

        :error ->
          {:halt, {:error, %{to: :map, key: key}}}
      end
    end)
  end

  def cast(map, %Schema{type: type}),
    do: {:error, %{to: type, value: map}}

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

defimpl Xema.Castable, for: Tuple do
  alias Xema.Schema

  def cast(tuple, %Schema{type: :any}), do: {:ok, tuple}

  def cast(tuple, %Schema{type: boolean}) when is_boolean(boolean), do: {:ok, tuple}

  def cast(tuple, %Schema{type: :tuple}), do: {:ok, tuple}

  def cast(tuple, %Schema{type: :list}), do: {:ok, Tuple.to_list(tuple)}

  def cast(tuple, %Schema{type: type}), do: {:error, %{to: type, value: tuple}}
end
