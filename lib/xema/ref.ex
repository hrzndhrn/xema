defmodule Xema.Ref do
  @moduledoc """
  This module contains a struct and function to represent and handle references.
  """

  import Xema.Utils, only: [get_value: 2, update_nil: 2]

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

  @keywords %Schema{}
            |> Map.keys()
            |> Enum.map(fn key -> Atom.to_string(key) end)

  @doc """
  Creates a new reference from the given `pointer`.
  """
  @spec new(String.t()) :: Ref.t()
  def new(pointer), do: %Ref{pointer: pointer}

  @spec new(String.t(), URI.t() | nil) :: Ref.t()
  def new("#" <> _ = pointer, _uri) do
    IO.inspect("--- Ref.new --- without uri")

    new(pointer)
  end

  def new(pointer, uri) when is_binary(pointer) do
    IO.inspect("--- Ref.new --- with uri")

    %Ref{
      pointer: pointer,
      uri: Utils.update_uri(uri, pointer)
    }
    |> IO.inspect()
  end

  @doc """
  Validates the given value with the referenced schema.
  """
  @spec validate(Ref.t(), any, keyword) :: :ok | {:error, map}
  def validate(ref, value, opts) do
    IO.inspect("--- validate ---")
    IO.inspect(ref, label: :ref, limit: :infinity)
    IO.inspect(opts[:id], label: :opts_id, limit: :infinity)
    root = opts[:root]

    unless is_nil(root.ids),
      do: IO.inspect(Map.keys(root.ids), label: :root_ids_keys)

    unless is_nil(root.refs),
      do: IO.inspect(Map.keys(root.refs), label: :root_ids_keys)

    # IO.inspect opts, label: :opts, limits: :infinity
    case get(ref, opts) do
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
    IO.inspect("--- get ---")
    IO.inspect(pointer)
    # IO.inspect(schema)
    IO.inspect(to_path(pointer))
    {:error, :not_found}
    %Xema{content: schema} = opts[:root]

    with {:ok, schema} <- get(schema, to_path(pointer)) do
      {:ok, schema, opts}
    end
  end

  defp get(nil, _), do: {:error, :not_found}

  defp get(schema, []), do: {:ok, schema}

  defp get(schema, [key | keys]),
    do:
      schema
      |> Mapz.get(decode(key))
      |> IO.inspect()
      |> get(keys)

  defp to_path("#" <> pointer),
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
  def to_string(ref), do: "{:ref, #{inspect(ref.pointer)}}"
end

defimpl String.Chars, for: Xema.Ref do
  @spec to_string(Xema.Ref.t()) :: String.t()
  def to_string(ref), do: Xema.Ref.to_string(ref)
end
