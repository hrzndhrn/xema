defmodule Xema.Ref do
  @moduledoc """
  TODO: doc
  """

  import Xema.Utils, only: [get_value: 2]

  alias Xema.Ref
  alias Xema.Schema

  @type t :: %Xema.Ref{pointer: String.t(), schema: Xema.t() | nil}

  defstruct pointer: "", schema: nil

  @spec new(keyword | String.t()) :: Ref.t()

  def new(str) when is_binary(str), do: %Ref{pointer: str}

  def new(opts), do: struct(Ref, opts)

  @spec get(Ref.t(), Xema.t() | Schema.t() | String.t() | nil) ::
          {:ok, Schema.t()} | {:error, atom}
  def get(ref, id) when is_binary(id), do: get(ref, ref.schema, id)

  def get(ref, schema), do: get(ref, schema, nil)

  @spec get(Ref.t(), Xema.t() | Schema.t(), String.t()) ::
          {:ok, Schema.t()} | {:error, atom}
  def get(ref, schema, id)

  def get(%Ref{pointer: "#"}, xema, _), do: {:ok, get_schema(xema)}

  def get(%Ref{pointer: "#/" <> pointer, schema: nil}, xema, _id) do
    do_get(pointer, xema)
  end

  def get(%Ref{pointer: "#/" <> pointer, schema: xema}, _xema, _id) do
    do_get(pointer, xema)
  end

  def get(%Ref{pointer: "http" <> _ = pointer, schema: schema}, _, _),
    do:
      pointer
      |> get_fragment()
      |> do_get(schema)

  def get(ref, xema, id) when not is_nil(id) do
    id =
      id
      |> URI.merge(ref.pointer)
      |> URI.to_string()

    case Map.get(xema.ids, id) do
      nil ->
        {:error, :not_found}

      id_ref ->
        get(id_ref, xema.content, nil)
    end
  end

  def get(_, _, _), do: {:error, :invalid_ref}

  defp do_get(_, nil), do: {:error, :not_found}

  defp do_get("#", xema), do: {:ok, get_schema(xema)}

  defp do_get("#" <> pointer, xema), do: do_get(pointer, xema)

  defp do_get(pointer, %Xema{} = xema)
       when is_binary(pointer),
       do: do_get(pointer, xema.content)

  defp do_get(pointer, schema)
       when is_binary(pointer),
       do:
         pointer
         |> String.trim("/")
         |> String.split("/")
         |> do_get(schema)

  defp do_get([], schema), do: {:ok, schema}

  defp do_get([step | steps], schema) when is_map(schema) do
    case get_value(schema, decode(step)) do
      {:ok, value} -> do_get(steps, value)
      {:error, _} -> {:error, :not_found}
    end
  end

  defp do_get([step | steps], schema) when is_list(schema) do
    with {:ok, index} <- to_integer(step) do
      case Enum.at(schema, index) do
        nil -> {:error, :not_found}
        value -> do_get(steps, value)
      end
    end
  end

  defp get_fragment(str) do
    case URI.parse(str) do
      %URI{fragment: nil} -> "#"
      %URI{fragment: fragment} -> fragment
    end
  end

  defp get_schema(schema) do
    case schema do
      %Xema{content: schema} -> schema
      %Schema{} = schema -> schema
      %Ref{schema: schema} -> schema
    end
  end

  defp decode(str) do
    str
    |> String.replace("~0", "~")
    |> String.replace("~1", "/")
    |> URI.decode()
  rescue
    _ -> str
  end

  defp to_integer(str) do
    case Regex.run(~r/\d+/, str) do
      nil -> {:error, :not_found}
      [int] -> {:ok, String.to_integer(int)}
    end
  end

  def to_string(ref) do
    "{:ref, #{inspect(ref.pointer)}}"
  end
end

defimpl String.Chars, for: Xema.Ref do
  @spec to_string(Xema.Ref.t()) :: String.t()
  def to_string(ref), do: Xema.Ref.to_string(ref)
end
