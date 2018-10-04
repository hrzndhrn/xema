defmodule Xema.Ref do
  @moduledoc """
  This module contains a struct and function to represent and handle references.
  """

  alias Xema.Mapz
  alias Xema.Ref
  alias Xema.Schema
  alias Xema.SchemaError
  alias Xema.Utils

  require Logger

  @type t :: %Xema.Ref{
          pointer: String.t(),
          uri: URI.t() | nil
        }

  defstruct pointer: nil,
            uri: nil

  @doc """
  Creates a new reference from the given `pointer`.
  """
  @spec new(String.t()) :: Ref.t()
  def new(pointer), do: %Ref{pointer: pointer}

  @spec new(String.t(), URI.t() | nil) :: Ref.t()
  def new("#" <> _ = pointer, _uri), do: new(pointer)

  def new(pointer, uri) when is_binary(pointer),
    do: %Ref{
      pointer: pointer,
      uri: Utils.update_uri(uri, pointer)
    }

  @doc """
  Validates the given value with the referenced schema.
  """
  @spec validate(Ref.t(), any, keyword) :: :ok | {:error, map}
  def validate(ref, value, opts) do
    case get(ref, opts) do
      {:ok, %Xema{} = xema, opts} ->
        Xema.validate(xema, value, opts)

      {:ok, %Schema{} = schema, opts} ->
        Xema.validate(schema, value, opts)

      {:ok, %Ref{} = ref, opts} ->
        validate(ref, value, opts)

      {:error, :not_found} ->
        raise SchemaError,
          message: "Reference '#{ref.pointer}' not found."
    end
  end

  defp get(%Ref{pointer: pointer, uri: nil}, opts) do
    with {:ok, schema} <- fetch_by_pointer(opts[:root], pointer),
         do: {:ok, schema, opts}
  end

  defp get(%Ref{uri: uri}, opts) do
    with {:ok, xema} <- fetch_by_id(uri, opts[:root]),
         {:ok, schema} <- fetch_by_fragment(xema, uri) do
      opts =
        case xema == schema do
          true -> opts
          false -> Keyword.put(opts, :root, xema)
        end

      {:ok, schema, opts}
    end
  end

  defp fetch_by_fragment(xema, %URI{fragment: nil}), do: {:ok, xema}

  defp fetch_by_fragment(%Xema{content: schema}, %URI{fragment: fragment}),
    do: fetch_by_path(schema, to_path(fragment))

  defp fetch_by_pointer(%Xema{content: schema}, "#"),
    do: fetch_by_path(schema, [])

  defp fetch_by_pointer(%Xema{content: schema}, "#/" <> _ = pointer),
    do: fetch_by_path(schema, to_path(pointer))

  defp fetch_by_pointer(%Xema{ids: ids}, pointer) do
    case Map.get(ids, pointer) do
      nil -> {:error, :not_found}
      val -> {:ok, val}
    end
  end

  defp fetch_by_path(nil, _), do: {:error, :not_found}

  defp fetch_by_path(schema, []), do: {:ok, schema}

  defp fetch_by_path(schemas, [key | keys]) when is_list(schemas) do
    index = String.to_integer(key)
    fetch_by_path(Enum.at(schemas, index), keys)
  rescue
    _ -> {:error, :not_found}
  end

  defp fetch_by_path(schema, [key | keys]) do
    key = decode(key)

    case Mapz.get(schema, key) do
      nil ->
        case Map.get(schema, :data) do
          nil -> nil
          val -> Mapz.get(val, key)
        end

      val ->
        val
    end
    |> fetch_by_path(keys)
  end

  defp fetch_by_id(_uri, %Xema{ids: nil}), do: {:error, :not_found}

  defp fetch_by_id(uri, %Xema{ids: ids}) do
    case Map.get(ids, URI.to_string(uri)) do
      nil -> {:error, :not_found}
      val -> {:ok, val}
    end
  end

  defp to_path("#" <> pointer), do: to_path(pointer)

  defp to_path(pointer),
    do:
      pointer
      |> String.split("/")
      |> Enum.filter(fn str -> str != "" end)

  defp decode(str) do
    str
    |> String.replace("~0", "~")
    |> String.replace("~1", "/")
    |> URI.decode()
  rescue
    _ -> str
  end

  @doc """
  Returns the binary representation of a reference.
  """
  @spec to_string(Ref.t()) :: String.t()
  def to_string(ref), do: ~s({:ref, "#{ref.pointer}"})
end

defimpl String.Chars, for: Xema.Ref do
  @spec to_string(Xema.Ref.t()) :: String.t()
  def to_string(ref), do: Xema.Ref.to_string(ref)
end
