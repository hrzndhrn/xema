defmodule Xema.Ref do
  @moduledoc false
  # This module contains a struct and functions to represent and handle
  # references.

  alias Xema.Ref
  alias Xema.Schema
  alias Xema.Utils

  require Logger

  @type t :: %Xema.Ref{
          pointer: String.t(),
          uri: URI.t() | nil
        }

  defstruct pointer: nil,
            uri: nil

  @compile {:inline, get_from_opts: 2}

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
    {schema, opts} = get_from_opts(ref, opts)
    Xema.validate(schema, value, opts)
  end

  @doc """
  Returns the schema for the given `ref` and `xema`.

  This function returns just schema they are defined in the root schema. Inlined
  schemas can not be found.
  """
  @spec get(Ref.t(), struct) :: Schema.t()
  def get(ref, xema) do
    with {%{} = schema, _} <- get_from_opts(ref, root: xema, master: xema) do
      schema
    else
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp get_from_opts(%Ref{pointer: "#", uri: nil}, opts),
    do: {opts[:root], opts}

  defp get_from_opts(%Ref{pointer: pointer, uri: nil}, opts),
    do: {Map.fetch!(opts[:root].refs, pointer), opts}

  defp get_from_opts(%Ref{uri: uri} = ref, opts) do
    key = key(ref)

    source =
      case master?(key, opts) do
        true -> :master
        false -> :root
      end

    case Map.fetch!(opts[source].refs, key) do
      %Schema{} = schema ->
        {schema, opts}

      :root ->
        {opts[:root], opts}

      xema ->
        opts = Keyword.put(opts, :root, xema)

        schema =
          case uri.fragment do
            nil -> xema
            "" -> xema
            fragment -> Map.fetch!(xema.refs, "##{fragment}")
          end

        {schema, opts}
    end
  end

  @doc """
  Returns the reference key.
  """
  @spec key(Ref.t()) :: String.t()
  def key(%Ref{pointer: pointer, uri: nil}), do: pointer

  def key(%Ref{uri: uri}), do: key(uri)

  def key(%URI{} = uri), do: uri |> Map.put(:fragment, nil) |> URI.to_string()

  defp master?(key, opts), do: Map.has_key?(opts[:master].refs, key)
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
