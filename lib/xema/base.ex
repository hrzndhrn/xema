defmodule Xema.Base do
  @moduledoc false

  alias Xema.NoResolver
  alias Xema.Ref
  alias Xema.Schema
  alias Xema.SchemaError
  alias Xema.Utils
  alias Xema.Validator

  defmacro __using__(_opts) do
    quote do
      import Xema.Base

      @enforce_keys [:content]

      @type t :: %__MODULE__{
              content: Schema.t(),
              ids: nil | map,
              refs: nil | map
            }

      defstruct [
        :content,
        :ids,
        :refs
      ]

      def new(data, opts \\ [])

      def new(%Schema{} = content, opts) do
        IO.inspect("--- base new ---")
        IO.inspect(content, limit: :infinity)
        IO.inspect(">>> ref ---")
        content = map_refs(content)

        IO.inspect("<<< ref ---")
        IO.inspect("-----------------------------------------------")

        struct(
          __MODULE__,
          content: content,
          ids: get_ids(content),
          refs: get_refs(content)
        )
      end

      def new(data, opts),
        do:
          data
          |> init(opts)
          |> new()

      @doc """
      Returns true if the value is a valid value against the given schema;
      otherwise returns false.
      """
      @spec is_valid?(__MODULE__.t(), any) :: boolean
      def is_valid?(schema, value), do: validate(schema, value) == :ok

      @doc """
      Returns `:ok` if the value is a valid value against the given schema;
      otherwise returns an error tuple.
      """
      @spec validate(__MODULE__.t(), any, keyword) :: Validator.result()
      def validate(xema, value, opts \\ [])

      def validate(%{__struct__: _, content: _} = xema, value, opts),
        do: do_validate(xema, value, opts)

      @spec validate(Schema.t(), any, keyword) :: Validator.result()
      def validate(%Schema{} = schema, value, opts),
        do: do_validate(schema, value, opts)

      defp do_validate(schema, value, opts) do
        case Validator.validate(schema, value, opts) do
          :ok ->
            :ok

          {:error, error} ->
            {:error, on_error(error)}
        end
      end

      defp on_error(error), do: error
      defoverridable on_error: 1

      defp map_refs(%Schema{} = schema) do
        map(schema, fn
          %Schema{ref: ref}, id when not is_nil(ref) ->
            IO.inspect(id, label: :ref_id)
            IO.inspect(ref, label: :ref)
            Ref.new(ref, id)

          %Schema{} = schema, id ->
            IO.inspect(id, label: :schema_id)
            schema

          value, id ->
            IO.inspect(id, label: :value_id)
            value
        end)
      end

      defp get_refs(%Schema{} = schema) do
        schema
        |> reduce(%{id: nil}, fn
          %Ref{} = ref, acc, _path ->
            put_ref(acc, ref)

          %Schema{id: id}, acc, _path when not is_nil(id) ->
            Utils.update_id(acc, id)

          _xema, acc, _path ->
            acc
        end)
        |> case do
          empty when empty == %{} -> nil
          refs -> Map.delete(refs, :id)
        end
      end

      defp put_ref(map, ref) do
        IO.inspect(ref)
        map
      end

      defp get_schema(uri) do
        case resolve(uri) do
          {:ok, data} ->
            new(data)

          {:error, reason} when is_binary(reason) ->
            raise SchemaError, message: reason

          {:error, reason} ->
            raise reason
        end
      end

      defp resolve(uri),
        do: Application.get_env(:xema, :resolver, NoResolver).get(uri)
    end
  end

  @spec get_ids(Schema.t()) :: map | nil
  def get_ids(%Schema{} = schema) do
    ids =
      reduce(schema, %{}, fn
        %Schema{id: id}, acc, path when not is_nil(id) ->
          Map.put(acc, id, Ref.new(path))

        _xema, acc, _path ->
          acc
      end)

    if ids == %{}, do: nil, else: ids
  end

  @spec reduce(Schema.t(), any, function) :: any
  def reduce(schema, acc, fun) do
    reduce(schema, acc, "#", fun)
  end

  defp reduce(%Schema{} = schema, acc, path, fun) do
    schema
    |> Map.from_struct()
    |> Enum.reduce(fun.(schema, acc, path), fn {key, value}, x ->
      reduce(value, x, Path.join(path, to_string(key)), fun)
    end)
  end

  defp reduce(%{__struct__: _struct} = struct, acc, path, fun),
    do: fun.(struct, acc, path)

  defp reduce(map, acc, path, fun) when is_map(map) do
    Enum.reduce(map, fun.(map, acc, path), fn
      {%{__struct__: _}, _value}, acc ->
        acc

      {key, value}, acc ->
        reduce(value, acc, Path.join(path, to_string(key)), fun)
    end)
  end

  defp reduce(value, acc, path, fun), do: fun.(value, acc, path)

  @spec map(Schema.t(), function) :: Schema.t() | Ref.t()
  def map(schema, fun) do
    map(schema, fun, nil)
  end

  defp map(%Schema{} = schema, fun, id) do
    id = Utils.update_uri(id, schema.id)

    case fun.(schema, id) do
      %Schema{} = schema ->
        struct(
          Schema,
          schema
          |> Map.to_list()
          |> Enum.map(fn {k, v} -> {k, map(v, fun, id)} end)
        )

      %Ref{} = ref ->
        ref
    end
  end

  defp map(%{__struct__: _} = struct, _fun, _id), do: struct

  defp map(map, fun, id) when is_map(map),
    do:
      map
      |> Map.to_list()
      |> Enum.into(%{}, fn {k, v} -> {k, map(v, fun, id)} end)

  defp map(list, fun, id) when is_list(list),
    do:
      list
      |> Enum.map(fn v -> map(v, fun, id) end)

  defp map(value, _fun, _id), do: value
end
