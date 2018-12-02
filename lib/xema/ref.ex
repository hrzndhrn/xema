defmodule Xema.Ref do
  @moduledoc """
  This module contains a struct and functions to represent and handle
  references.
  """

  alias Xema.Ref
  alias Xema.RefError
  alias Xema.Schema
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

  @doc """
  Creates a new reference from the given `pointer` and `uri`.
  """
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
  @spec validate(Ref.t() | Schema.t() | Xema.t(), any, keyword) ::
          :ok | {:error, map}
  def validate(ref, value, opts) do
    case get(ref, opts) do
      {:ok, %Schema{} = schema, opts} ->
        Xema.validate(schema, value, opts)

      {:ok, %Ref{} = ref, opts} ->
        validate(ref, value, opts)

      {:ok, %{} = xema, opts} ->
        Xema.validate(xema, value, opts)

      {:error, :not_found} ->
        raise RefError, {:not_found, ref.pointer}
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

  defp fetch_by_fragment(%{schema: schema}, %URI{fragment: fragment}),
    do: fetch_by_path(schema, to_path(fragment))

  defp fetch_by_pointer(%{schema: schema}, "#"),
    do: fetch_by_path(schema, [])

  defp fetch_by_pointer(%{schema: schema}, "#/" <> _ = pointer),
    do: fetch_by_path(schema, to_path(pointer))

  defp fetch_by_pointer(%{refs: refs}, pointer) do
    case Map.get(refs, pointer) do
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

    schema
    |> get_value(key)
    |> case do
      nil ->
        case Map.get(schema, :data) do
          nil -> nil
          val -> get_value(val, key)
        end

      val ->
        val
    end
    |> fetch_by_path(keys)
  end

  defp fetch_by_id(_uri, %{refs: nil}), do: {:error, :not_found}

  defp fetch_by_id(uri, %{refs: refs}) do
    case Map.get(refs, URI.to_string(uri)) do
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
  end

  @spec get_value(map, String.t()) :: any
  defp get_value(map, key) when is_binary(key) do
    case {Map.get(map, key), Map.get(map, Utils.to_existing_atom(key))} do
      {nil, nil} -> nil
      {value, nil} -> value
      {nil, value} -> value
    end
  end
end

defimpl Inspect, for: Xema.Ref do
  def inspect(schema, opts) do
    map =
      schema
      |> Map.from_struct()
      |> Enum.filter(fn {_, val} -> !is_nil(val) end)
      |> Enum.into(%{})

    Inspect.Map.inspect(map, "Xema.Ref", opts)
  end
end
