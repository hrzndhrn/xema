defmodule Xema.Behaviour do
  @moduledoc """
  A behaviour module for implementing a schema validator.
  """

  alias Xema.NoResolver
  alias Xema.Ref
  alias Xema.Schema
  alias Xema.Utils
  alias Xema.Validator

  alias Xema.SchemaError
  alias Xema.ValidationError

  @doc """
  This callback initialize the schema. The function gets the data given to
  `Xema.new/1` and returns a `Xema.Schema`.
  """
  @callback init(any) :: Schema.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour Xema.Behaviour
      alias Xema.Behaviour

      @enforce_keys [:schema]

      @type t :: %__MODULE__{
              schema: Schema.t(),
              refs: map
            }

      defstruct schema: %Schema{},
                refs: %{}

      def new(%Schema{} = schema) do
        schema = Behaviour.map_refs(schema)
        refs = Behaviour.get_refs(schema)
        ids = Behaviour.get_ids(schema)

        struct!(
          __MODULE__,
          schema: schema,
          refs: Map.merge(ids, refs)
        )
      end

      def new(data), do: data |> init() |> new()

      @doc """
      Returns `true` if the `value` is a valid value against the given `schema`;
      otherwise returns `false`.

      ## Examples

          iex> schema = Xema.new({:integer, minimum: 1})
          iex> Xema.valid?(schema, 2)
          true
          iex> Xema.valid?(schema, 1)
          true
          iex> Xema.valid?(schema, 0)
          false
      """
      @spec valid?(__MODULE__.t() | Schema.t(), any) :: boolean
      def valid?(schema, value), do: validate(schema, value) == :ok

      @doc """
      Returns `true` if the `value` is a valid value against the given `schema`;
      otherwise returns `false`.
      """
      @deprecated "Use valid? instead"
      @spec is_valid?(__MODULE__.t() | Schema.t(), any) :: boolean
      def is_valid?(schema, value), do: validate(schema, value) == :ok

      @doc """
      Returns `:ok` if the `value` is a valid value against the given `schema`;
      otherwise returns an error tuple.
      """
      @spec validate(__MODULE__.t() | Schema.t(), any) :: Validator.result()
      def validate(schema, value), do: validate(schema, value, [])

      @doc false
      @spec validate(__MODULE__.t(), any, keyword) :: Validator.result()
      def validate(%__MODULE__{} = schema, value, opts),
        do: do_validate(schema, value, opts)

      @spec validate(Schema.t(), any, keyword) :: Validator.result()
      def validate(%Schema{} = schema, value, opts),
        do: do_validate(schema, value, opts)

      defp do_validate(schema, value, opts) do
        with {:error, error} <- Validator.validate(schema, value, opts),
             do: {:error, on_error(error)}
      end

      @doc """
      Returns `:ok` if the `value` is a valid value against the given `schema`;
      otherwise raises a `Xema.ValidationError`.
      """
      @spec validate!(Xema.t() | Schema.t(), any) :: :ok
      def validate!(xema, value) do
        with {:error, reason} <- validate(xema, value),
             do: raise(ValidationError, reason)
      end

      # This function can be overwritten to transform the reason map of an
      # error tuple.
      defp on_error(error), do: error
      defoverridable on_error: 1
    end
  end

  @doc false
  @spec map_refs(Schema.t()) :: Schema.t()
  def map_refs(%Schema{} = schema) do
    map(schema, fn
      %Schema{ref: ref} = schema, id when not is_nil(ref) ->
        %{schema | ref: Ref.new(ref, id)}

      value, _id ->
        value
    end)
  end

  @doc false
  @spec get_refs(Schema.t()) :: %{required(String.t()) => Ref.t()}
  def get_refs(%Schema{} = schema) do
    schema
    |> reduce(%{id: nil}, fn
      %Ref{} = ref, acc, _path ->
        put_ref(acc, ref)

      %Schema{id: id}, acc, _path when not is_nil(id) ->
        update_id(acc, id)

      _schema, acc, _path ->
        acc
    end)
    |> case do
      empty when empty == %{} -> nil
      refs -> Map.delete(refs, :id)
    end
  end

  @doc false
  @spec get_ids(Schema.t()) :: map | nil
  def get_ids(%Schema{} = schema) do
    reduce(schema, %{}, fn
      %Schema{id: id}, acc, path when not is_nil(id) ->
        Map.put(acc, id, Ref.new(path))

      _xema, acc, _path ->
        acc
    end)
  end

  defp update_id(%{id: a} = map, b),
    do: Map.put(map, :id, Utils.update_uri(a, b))

  defp put_ref(map, %Ref{uri: uri}) when not is_nil(uri) do
    case get_schema(uri) do
      nil ->
        map

      schema ->
        Map.put(map, URI.to_string(uri), schema)
    end
  end

  defp put_ref(map, _), do: map

  defp get_schema(uri) do
    case resolve(uri) do
      {:ok, nil} ->
        nil

      {:ok, data} ->
        Xema.new(data)

      {:error, reason} ->
        raise SchemaError, reason
    end
  end

  defp resolve(uri),
    do: Application.get_env(:xema, :resolver, NoResolver).fetch(uri)

  @spec reduce(Schema.t(), any, function) :: any
  defp reduce(schema, acc, fun) do
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

  # Returns a schema tree where each schema is the result of invoking `fun` on
  # each schema. The function gets also the current `ìd` for the schema. The
  # `id` could be `nil` or a `%URI{}` struct.
  @doc false
  @spec map(Schema.t(), function) :: Schema.t() | Ref.t()
  defp map(schema, fun), do: map(schema, fun, nil)

  defp map(%Schema{} = schema, fun, id) do
    id = Utils.update_uri(id, schema.id)

    struct(
      Schema,
      schema
      |> fun.(id)
      |> Map.from_struct()
      |> Enum.map(fn {k, v} -> {k, map(v, fun, id)} end)
    )
  end

  defp map(%{__struct__: _} = struct, _fun, _id), do: struct

  defp map(map, fun, id) when is_map(map),
    do: Enum.into(map, %{}, fn {k, v} -> {k, map(v, fun, id)} end)

  defp map(list, fun, id) when is_list(list),
    do: Enum.map(list, fn v -> map(v, fun, id) end)

  defp map(value, _fun, _id), do: value
end
