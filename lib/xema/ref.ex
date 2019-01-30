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
  def validate(%Ref{pointer: "#", uri: nil}, value, opts),
    do: Xema.validate(opts[:root], value, opts)

  def validate(%Ref{pointer: pointer, uri: nil}, value, opts),
    do:
      opts[:root].refs
      |> Map.fetch!(pointer)
      |> Xema.validate(value, opts)

  def validate(%Ref{uri: uri}, value, opts) do
    key = uri |> Map.put(:fragment, nil) |> URI.to_string()

    source =
      case master?(key, opts) do
        true -> :master
        false -> :root
      end

    case Map.fetch!(opts[source].refs, key) do
      %Schema{} = schema ->
        Xema.validate(schema, value, opts)

      :root ->
        Xema.validate(opts[:root], value, opts)

      xema ->
        opts = Keyword.put(opts, :root, xema)

        schema =
          case uri.fragment do
            nil -> xema
            fragment -> Map.fetch!(xema.refs, "##{fragment}")
          end

        Xema.validate(schema, value, opts)
    end
  end

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
