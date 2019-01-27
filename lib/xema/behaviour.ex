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
              schema: any,
              refs: any
            }

      defstruct schema: %Schema{},
                refs: %{}

      def new(data, opts \\ [])

      def new(%Schema{} = schema, opts) do
        schema = Behaviour.map_refs(schema)
        remotes = Behaviour.get_remote_refs(schema, __MODULE__, opts)

        xema =
          struct!(
            __MODULE__,
            schema: schema,
            refs: remotes
          )

        case opts[:remotes] do
          nil -> Behaviour.update_remote_refs(xema)
          _remotes -> xema
        end
      end

      def new(data, opts), do: data |> init() |> new(opts)

      @doc """
      Returns `true` if the `value` is a valid value against the given `schema`;
      otherwise returns `false`.
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
      @spec validate(Schema.t(), any, keyword) :: Validator.result()
      def validate(%Schema{} = schema, value, opts),
        do: do_validate(schema, value, opts)

      @spec validate(__MODULE__.t(), any, keyword) :: Validator.result()
      def validate(%{} = schema, value, opts),
        do: do_validate(schema, value, opts)

      defp do_validate(schema, value, opts) do
        with {:error, error} <- Validator.validate(schema, value, opts),
             do: {:error, on_error(error)}
      end

      @doc """
      Returns `:ok` if the `value` is a valid value against the given `schema`;
      otherwise raises a `Xema.ValidationError`.
      """
      @spec validate!(__MODULE__.t() | Schema.t(), any) :: :ok
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
  # @spec update_remote_refs(%{required(String.t()) => __MODULE__.t()}) ::
  # %{required(String.t()) => __MODULE__.t()}
  def update_remote_refs(xema) do
    refs_map =
      xema.refs
      |> Map.keys()
      |> Enum.reduce(%{master: []}, fn key, acc -> Map.put(acc, key, []) end)
      |> get_refs_map(:master, xema)

    refs_map =
      Enum.reduce(xema.refs, refs_map, fn {key, xema}, acc ->
        get_refs_map(acc, key, xema)
      end)

    xema
    |> do_update_refs(Map.fetch!(refs_map, :master))
    |> do_update_refs_refs(refs_map)
    |> do_update_refs_ids()
    |> do_update_refs_refs_ids()
  end

  defp do_update_refs_ids(%{schema: schema} = xema)
       when not is_nil(schema),
       do:
         Map.update!(xema, :refs, fn value ->
           Map.merge(value, get_ids(schema))
         end)

  defp do_update_refs_ids(value), do: value

  defp do_update_refs_refs_ids(%{refs: refs} = xema) do
    refs =
      Enum.into(refs, %{}, fn {key, ref} -> {key, do_update_refs_ids(ref)} end)

    Map.update!(xema, :refs, fn value ->
      Map.merge(value, refs)
    end)
  end

  defp do_update_refs(%{schema: schema} = xema, refs),
    do:
      Map.update!(xema, :refs, fn value ->
        Map.merge(value, get_schema_refs(schema, refs))
      end)

  defp do_update_refs_refs(%{refs: refs} = xema, refs_map) do
    refs =
      Enum.into(refs, %{}, fn {key, ref} ->
        case Map.has_key?(refs_map, key) do
          true ->
            {key, do_update_refs(ref, Map.get(refs_map, key))}

          false ->
            {key, ref}
        end
      end)

    Map.update!(xema, :refs, fn value ->
      Map.merge(value, refs)
    end)
  end

  defp get_schema_refs(schema, refs),
    do:
      Enum.into(refs, %{}, fn key ->
        {key, Schema.fetch!(schema, key)}
      end)

  @doc false
  def get_refs_map(refs, key, %{schema: schema}) do
    reduce(schema, refs, fn
      %Ref{pointer: pointer, uri: nil}, acc, _path ->
        case pointer do
          "#/" <> _ -> Map.update!(acc, key, fn list -> [pointer | list] end)
          _ -> acc
        end

      %Ref{uri: uri} = ref, acc, _path ->
        case ref.uri.fragment do
          nil ->
            acc

          fragment ->
            key = uri |> Map.put(:fragment, nil) |> URI.to_string()
            Map.update!(acc, key, fn list -> ["##{fragment}" | list] end)
        end

      _schem, acc, _path ->
        acc
    end)
  end

  @doc false
  @spec get_remote_refs(Schema.t(), atom, keyword) :: %{
          required(String.t()) => Ref.t()
        }
  def get_remote_refs(%Schema{} = schema, module, opts) do
    reduce(schema, %{}, fn
      %Ref{} = ref, acc, _path ->
        put_remote_ref(acc, ref, module, opts)

      _, acc, _path ->
        acc
    end)
  end

  @doc false
  @spec get_ids(Schema.t()) :: map | nil
  defp get_ids(%Schema{} = schema) do
    reduce(schema, %{}, fn
      %Schema{id: id}, acc, path when not is_nil(id) ->
        case path == "#" do
          false ->
            Map.put(acc, id, Schema.fetch!(schema, path))

          true ->
            Map.put(acc, id, :root)
        end

      _xema, acc, _path ->
        acc
    end)
  end

  defp put_remote_ref(map, %Ref{uri: uri} = ref, module, opts) do
    case remote?(ref) do
      false ->
        map

      true ->
        key = uri |> Map.put(:fragment, nil) |> URI.to_string()
        remote_set = opts[:remotes] || MapSet.new()

        case MapSet.member?(remote_set, key) do
          true ->
            map

          false ->
            remote_set = MapSet.put(remote_set, key)

            schema =
              get_remote_schema(
                ref,
                module,
                Keyword.put(opts, :remotes, remote_set)
              )

            remotes = schema.refs
            schema = Map.put(schema, :refs, %{})

            map
            |> Map.put(key, schema)
            |> Map.merge(remotes)
        end
    end
  end

  defp get_remote_schema(ref, module, opts) do
    case resolve(ref.uri, opts[:resolver]) do
      {:ok, nil} ->
        nil

      {:ok, data} ->
        module.new(data, opts)

      {:error, reason} ->
        raise SchemaError, reason
    end
  end

  defp resolve(uri, nil),
    do: Application.get_env(:xema, :resolver, NoResolver).fetch(uri)

  defp resolve(uri, resolver), do: resolver.fetch(uri)

  defp remote?(%Ref{uri: nil}), do: false

  defp remote?(%Ref{uri: %URI{path: nil}}), do: false

  defp remote?(%Ref{uri: %URI{path: path}, pointer: pointer}),
    do:
      Regex.match?(~r/(\.[a-zA-Z]+)|\#$/, path) or
        String.ends_with?(pointer, "#")

  # Invokes `fun` for each element in the schema tree with the accumulator.
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

  defp reduce(list, acc, path, fun) when is_list(list),
    do:
      Enum.reduce(list, acc, fn value, acc ->
        reduce(value, acc, path, fun)
      end)

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
