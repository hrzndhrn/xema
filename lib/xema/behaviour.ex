defmodule Xema.Behaviour do
  @moduledoc """
  A behaviour module for implementing a schema validator. This behaviour is
  just for `Xema` and `JsonXema`.
  """

  alias Xema.{
    JsonSchema,
    Loader,
    Ref,
    Schema,
    SchemaError,
    Utils,
    ValidationError,
    Validator
  }

  @typedoc """
  The schema containter.
  """
  @type t :: struct

  @inline_default true

  @doc """
  This callback initialize the schema. The function gets the data given to
  `Xema.new/1` and returns a `Xema.Schema`.
  """
  @callback init(any, keyword) :: Schema.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour Xema.Behaviour
      alias Xema.Behaviour

      @enforce_keys [:schema]

      @typedoc """
      This struct contains the schema and references of the schema.
      """
      @type t :: %__MODULE__{
              schema: Schema.t(),
              refs: map
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
          nil -> Behaviour.update_refs(xema, opts)
          _remotes -> xema
        end
      end

      def new(data, opts) when is_map(data) or is_tuple(data) or is_list(data) or is_atom(data) do
        data |> init(opts) |> new(opts)
      end

      @doc """
      Returns `true` if the `value` is a valid value against the given `schema`;
      otherwise returns `false`.
      """
      @spec valid?(__MODULE__.t() | Schema.t(), any) :: boolean
      def valid?(schema, value), do: validate(schema, value) == :ok

      @doc """
      Returns `:ok` if the `value` is a valid value against the given `schema`;
      otherwise returns an error tuple.
      """
      @spec validate(__MODULE__.t() | Schema.t(), any) :: Validator.result()
      def validate(schema, value), do: validate(schema, value, [])

      @doc false
      @spec validate(__MODULE__.t() | Schema.t(), any, keyword) :: Validator.result()
      def validate(%{} = schema, value, opts) do
        with {:error, error} <- Validator.validate(schema, value, opts),
             do: {:error, on_error(error)}
      end

      @doc """
      Returns `:ok` if the `value` is a valid value against the given `schema`;
      otherwise raises a `#{__MODULE__}.ValidationError`.
      """
      @spec validate!(__MODULE__.t() | Schema.t(), any) :: :ok
      def validate!(xema, value) do
        with {:error, reason} <- validate(xema, value),
             do: raise(reason)
      end

      # This function can be overwritten to transform the reason map of an error tuple.
      defp on_error(error), do: ValidationError.exception(reason: error)
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
  def update_refs(xema, opts) do
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
    |> update_master_refs(Map.fetch!(refs_map, :master))
    |> update_remote_refs(refs_map)
    |> update_master_ids()
    |> update_remote_ids()
    |> inline(opts)
  end

  defp inline(xema, opts) do
    case Keyword.get(opts, :inline, @inline_default) do
      true -> inline(xema)
      false -> xema
    end
  end

  defp inline(xema) do
    xema.refs
    |> Map.keys()
    |> Enum.filter(fn ref -> circular?(xema, ref) end)
    |> inline_refs(xema)
  end

  defp inline_refs(circulars, xema) do
    schema = inline_refs(circulars, xema, nil, xema.schema)

    refs =
      xema.refs
      |> Enum.map(fn {ref, schema} = item ->
        case {ref in circulars, schema} do
          {false, _} ->
            item

          {true, :root} ->
            item

          {true, %Schema{} = schema} ->
            {ref, inline_refs(circulars, xema, xema, schema)}

          {true, %{schema: %Schema{} = schema} = master} ->
            {ref, Map.put(master, :schema, inline_refs(circulars, master, xema, schema))}
        end
      end)
      |> Enum.filter(fn {ref, _} -> Enum.member?(circulars, ref) end)
      |> Enum.into(%{})

    %{xema | schema: schema, refs: refs}
  end

  defp inline_refs(circulars, master, root, %Schema{} = schema) do
    map(schema, fn
      %Schema{ref: ref} = schema, _id when not is_nil(ref) ->
        case Enum.member?(circulars, Ref.key(ref)) do
          true ->
            schema

          false ->
            case Ref.fetch!(ref, master, root) do
              {%Schema{} = ref_schema, root} ->
                inline_refs(circulars, master, root, ref_schema)

              {xema, xema} ->
                schema

              {xema, root} ->
                inline_refs(circulars, xema, root, xema.schema)
            end
        end

      value, _id ->
        value
    end)
  end

  defp update_master_ids(%{schema: schema} = xema) when not is_nil(schema) do
    Map.update!(xema, :refs, fn value ->
      Map.merge(value, get_ids(schema))
    end)
  end

  defp update_master_ids(value), do: value

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

  defp update_remote_ids(%{refs: refs} = xema) do
    refs = Enum.into(refs, %{}, fn {key, ref} -> {key, update_master_ids(ref)} end)

    Map.update!(xema, :refs, fn value ->
      Map.merge(value, refs)
    end)
  end

  defp update_master_refs(%{schema: schema} = xema, refs),
    do:
      Map.update!(xema, :refs, fn value ->
        Map.merge(value, get_schema_refs(schema, refs))
      end)

  defp update_remote_refs(%{refs: refs} = xema, refs_map) do
    refs =
      Enum.into(refs, %{}, fn {key, ref} ->
        case Map.has_key?(refs_map, key) do
          true ->
            {key, update_master_refs(ref, Map.get(refs_map, key))}

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

  defp get_refs_map(refs, key, %{schema: schema}) do
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

          "" ->
            acc

          fragment ->
            key = Ref.key(uri)
            Map.update!(acc, key, fn list -> ["##{fragment}" | list] end)
        end

      _value, acc, _path ->
        acc
    end)
  end

  @doc false
  @spec get_remote_refs(Schema.t(), atom, keyword) ::
          %{required(String.t()) => struct}
  def get_remote_refs(%Schema{} = schema, module, opts) do
    reduce(schema, %{}, fn
      %Ref{} = ref, acc, _path ->
        put_remote_ref(acc, ref, module, opts)

      _, acc, _path ->
        acc
    end)
  end

  defp put_remote_ref(map, %Ref{uri: uri} = ref, module, opts) do
    case remote?(ref) do
      false ->
        map

      true ->
        key = Ref.key(uri)
        remote_set = opts[:remotes] || MapSet.new()

        case MapSet.member?(remote_set, key) do
          true ->
            map

          false ->
            remote_set = MapSet.put(remote_set, key)

            xema =
              get_remote_schema(
                ref,
                module,
                Keyword.put(opts, :remotes, remote_set)
              )

            remotes = xema.refs
            xema = Map.put(xema, :refs, %{})

            map
            |> Map.put(key, xema)
            |> Map.merge(remotes)
        end
    end
  end

  defp get_remote_schema(ref, module, opts) do
    case resolve(ref.uri, opts[:loader]) do
      {:ok, nil} ->
        nil

      {:ok, data} ->
        case Keyword.get(opts, :draft, :xema) do
          :xema -> module.new(data, opts)
          draft -> data |> JsonSchema.to_xema(opts) |> module.new(opts)
        end

      {:error, reason} ->
        raise SchemaError, reason
    end
  end

  defp resolve(uri, nil), do: Loader.fetch(uri)

  defp resolve(uri, loader), do: loader.fetch(uri)

  defp remote?(%Ref{uri: nil}), do: false

  defp remote?(%Ref{uri: %URI{path: nil}}), do: false

  defp remote?(%Ref{uri: %URI{path: path}, pointer: pointer}),
    do:
      Regex.match?(~r/(\.[a-zA-Z]+)|\#$/, path) or
        String.ends_with?(pointer, "#")

  # Invokes `fun` for each element in the schema tree with the accumulator.
  @spec reduce(Schema.t(), any, function) :: any
  defp reduce(schema, acc, fun), do: reduce(schema, acc, "#", fun)

  defp reduce(%Schema{} = schema, acc, path, fun),
    do:
      schema
      |> Map.from_struct()
      |> Enum.reduce(fun.(schema, acc, path), fn {key, value}, x ->
        reduce(value, x, Path.join(path, to_string(key)), fun)
      end)

  defp reduce(%_{} = struct, acc, path, fun),
    do: fun.(struct, acc, path)

  defp reduce(map, acc, path, fun) when is_map(map),
    do:
      Enum.reduce(map, fun.(map, acc, path), fn
        {%key{}, value}, acc ->
          reduce(value, acc, Path.join(path, to_string(key)), fun)

        {key, value}, acc ->
          reduce(value, acc, Path.join(path, to_string(key)), fun)
      end)

  defp reduce(list, acc, path, fun) when is_list(list),
    do:
      Enum.reduce(list, acc, fn value, acc ->
        reduce(value, acc, path, fun)
      end)

  defp reduce(nil, acc, _path, _fun), do: acc

  defp reduce(value, acc, path, fun), do: fun.(value, acc, path)

  # Returns a schema tree where each schema is the result of invoking `fun` on
  # each schema. The function gets also the current `ìd` for the schema. The
  # `id` could be `nil` or a `%URI{}` struct.
  @spec map(Schema.t(), function) :: Schema.t() | Ref.t()
  defp map(schema, fun), do: map(schema, fun, nil)

  defp map(%Schema{} = schema, fun, id) do
    id = Utils.update_uri(id, schema.id)

    Schema
    |> struct(
      schema
      |> Map.from_struct()
      |> Enum.map(fn {k, v} -> {k, map(v, fun, id)} end)
    )
    |> fun.(id)
  end

  defp map(%_{} = struct, _fun, _id), do: struct

  defp map(map, fun, id) when is_map(map),
    do: Enum.into(map, %{}, fn {k, v} -> {k, map(v, fun, id)} end)

  defp map(list, fun, id) when is_list(list),
    do: Enum.map(list, fn v -> map(v, fun, id) end)

  defp map(value, _fun, _id), do: value

  # Returns true if the `reference` builds up a circular reference.
  @spec circular?(struct(), String.t()) :: boolean
  defp circular?(xema, reference),
    do: circular?(xema.refs[reference], reference, xema, [])

  defp circular?(%Ref{} = ref, reference, root, acc) do
    key = Ref.key(ref)

    with false <- key == reference,
         false <- key == "#" do
      case Enum.member?(acc, key) do
        true -> false
        false -> circular?(root.refs[key], reference, root, [key | acc])
      end
    end
  end

  defp circular?(%_{} = struct, reference, root, acc),
    do: struct |> Map.from_struct() |> circular?(reference, root, acc)

  defp circular?(values, reference, root, acc)
       when is_map(values),
       do:
         Enum.any?(values, fn {_, value} ->
           circular?(value, reference, root, acc)
         end)

  defp circular?(values, reference, root, acc)
       when is_list(values),
       do:
         Enum.any?(values, fn value ->
           circular?(value, reference, root, acc)
         end)

  defp circular?(:root, _reference, _root, _acc), do: true

  defp circular?(_ref, _reference, _root, _acc), do: false
end
