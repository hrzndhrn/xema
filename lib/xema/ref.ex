defmodule Xema.Ref do
  @moduledoc false
  # This module contains a struct and functions to represent and handle
  # references.

  alias Xema.Ref
  alias Xema.Schema
  alias Xema.Utils

  require Logger

  @typedoc """
  A reference contains a `pointer` and an optional `uri`.
  """
  @type t :: %Xema.Ref{
          pointer: String.t(),
          uri: URI.t() | nil
        }

  defstruct pointer: nil,
            uri: nil

  @compile {:inline, fetch_from_opts!: 2, fetch_by_key!: 3}

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
  @spec validate(Ref.t(), any, keyword) ::
          :ok | {:error, map}
  def validate(ref, value, opts) do
    {schema, opts} = fetch_from_opts!(ref, opts)
    Xema.validate(schema, value, opts)
  end

  @doc """
  Returns the schema and the root for the given `ref` and `xema`.
  """
  @spec fetch!(Ref.t(), struct, struct | nil) :: {struct | atom, struct}
  def fetch!(ref, master, root) do
    case fetch_by_key!(key(ref), master, root) do
      {%Schema{}, _root} = schema ->
        schema

      {xema, root} ->
        case fragment(ref) do
          nil ->
            {xema, root}

          fragment ->
            {Map.fetch!(xema.refs, fragment), xema}
        end
    end
  end

  @doc """
  Returns the reference key for a `Ref` or an `URI`.
  """
  @spec key(ref :: Ref.t() | URI.t() ) :: String.t()
  def key(%Ref{pointer: pointer, uri: nil}), do: pointer

  def key(%Ref{uri: uri}), do: key(uri)

  def key(%URI{} = uri), do: uri |> Map.put(:fragment, nil) |> URI.to_string()

  def fragment(%Ref{uri: nil}), do: nil

  def fragment(%Ref{uri: %URI{fragment: nil}}), do: nil

  def fragment(%Ref{uri: %URI{fragment: ""}}), do: nil

  def fragment(%Ref{uri: %URI{fragment: fragment}}), do: "##{fragment}"

  defp fetch_from_opts!(%Ref{pointer: "#", uri: nil}, opts),
    do: {opts[:root], opts}

  defp fetch_from_opts!(%Ref{pointer: pointer, uri: nil}, opts),
    do: {Map.fetch!(opts[:root].refs, pointer), opts}

  defp fetch_from_opts!(%Ref{} = ref, opts) do
    case fetch!(ref, opts[:master], opts[:root]) do
      {:root, root} ->
        {root, Keyword.put(opts, :root, root)}

      {%Schema{} = schema, root} ->
        {schema, Keyword.put(opts, :root, root)}

      {xema, _} ->
        {xema, Keyword.put(opts, :root, xema)}
    end
  end

  defp fetch_by_key!("#", master, nil), do: {master, master}

  defp fetch_by_key!("#", _master, root), do: {root, root}

  defp fetch_by_key!(key, master, nil),
    do: {Map.fetch!(master.refs, key), master}

  defp fetch_by_key!(key, master, root) do
    case Map.get(root.refs, key) do
      nil -> {Map.fetch!(master.refs, key), master}
      schema -> {schema, root}
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
