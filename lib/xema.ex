defmodule Xema do
  @moduledoc """
  A schema validator inspired by [JSON Schema](http://json-schema.org)
  """

  use Xema.Base

  alias Xema.Ref
  alias Xema.Schema
  alias Xema.Schema.Validator, as: Validator
  alias Xema.SchemaError

  @typedoc """
  The available type notations.
  """
  @type schema_types ::
          :any
          | :boolean
          | :float
          | :integer
          | :list
          | :map
          | nil
          | :number
          | :string

  @schema_types [
    :any,
    :boolean,
    :float,
    :integer,
    :list,
    :map,
    nil,
    :number,
    :string
  ]

  @typedoc """
  The available schema keywords.
  """
  @type schema_keywords ::
          :additional_items
          | :additional_properties
          | :all_of
          | :any_of
          | :definitions
          | :dependencies
          | :enum
          | :exclusive_maximum
          | :exclusive_minimum
          | :format
          | :id
          | :items
          | :keys
          | :max_items
          | :max_length
          | :max_properties
          | :maximum
          | :min_items
          | :min_length
          | :min_properties
          | :minimum
          | :multiple_of
          | :not
          | :one_of
          | :pattern
          | :pattern_properties
          | :properties
          | :ref
          | :required
          | :unique_items

  @schema_keywords [
    :additional_items,
    :additional_properties,
    :all_of,
    :any_of,
    :definitions,
    :dependencies,
    :enum,
    :exclusive_maximum,
    :exclusive_minimum,
    :format,
    :id,
    :items,
    :keys,
    :max_items,
    :max_length,
    :max_properties,
    :maximum,
    :min_items,
    :min_length,
    :min_properties,
    :minimum,
    :multiple_of,
    :not,
    :one_of,
    :pattern,
    :pattern_properties,
    :properties,
    :ref,
    :required,
    :unique_items
  ]

  @doc """
  This function defines the schemas.

  The first argument sets the `type` of the schema. The second arguments
  contains the 'keywords' of the schema.

  ## Parameters

    - type: type of the schema.
    - opts: keywords of the schema.

  ## Examples

      iex> Xema.new :string, min_length: 3, max_length: 12
      %Xema{
        content: %Xema.Schema{
          max_length: 12,
          min_length: 3,
          type: :string,
          as: :string
        }
      }

  For nested schemas you can use `{:type, opts: ...}` like here.

  ## Examples
      iex> schema = Xema.new :list, items: {:number, minimum: 2}
      %Xema{
        content: %Xema.Schema{
          type: :list,
          as: :list,
          items: %Xema.Schema{
            type: :number,
            as: :number,
            minimum: 2
          }
        }
      }
      iex> Xema.validate(schema, [2, 3, 4])
      :ok
      iex> Xema.is_valid?(schema, [2, 3, 4])
      true
      iex> Xema.validate(schema, [2, 3, 1])
      {:error, [{2, %{value: 1, minimum: 2}}]}

  """

  # @spec new(schema_types | schema_keywords | tuple, keyword) :: Xema.t()
  # def x_new(type, keywords \\ [])

  def init({type}, []), do: init(type, [])

  def init(list, []) when is_list(list) do
    case Keyword.keyword?(list) do
      true -> init(:any, list)
      false -> multi_type(list, [])
    end
  end

  def init(list, keywords) when is_list(list), do: multi_type(list, keywords)

  def init({type, keywords}, []), do: init(type, keywords)

  def init(tuple, keywords) when is_tuple(tuple),
    do: raise(ArgumentError, message: "Invalid argument #{inspect(keywords)}.")

  def init(bool, [])
      when is_boolean(bool),
      do: Schema.new(type: bool)

#  def init(:ref, remote) when is_binary(remote) do
#    uri = del_fragment(remote)
#
#    case remote_schema(uri) do
#      {:ok, schema} ->
#        [pointer: remote, schema: schema]
#        |> Ref.new()
#
#      {:error, %SyntaxError{description: desc, line: line}} ->
#        raise SyntaxError, description: desc, line: line, file: uri
#
#      {:error, %CompileError{description: desc, line: line}} ->
#        raise CompileError, description: desc, line: line, file: uri
#
#      {:error, _error} ->
#        raise SchemaError, message: "Remote schema '#{remote}' not found."
#    end
#  end

  for type <- @schema_types do
    def init(unquote(type), opts), do: schema({unquote(type), opts}, [])
  end

  for keyword <- @schema_keywords do
    def init(unquote(keyword), opts), do: init(:any, [{unquote(keyword), opts}])
  end

  defp multi_type(list, keywords) when is_list(list) do
    case Enum.all?(list, fn type -> type in @schema_types end) do
      true ->
        schema({list, keywords}, [])

      false ->
        raise(
          ArgumentError,
          message: "Invalid type in argument list #{inspect(list)}."
        )
    end
  end

  #
  # function: schema
  #
  @spec schema(any, keyword) :: Xema.Schema.t()

  defp schema(list, opts) when is_list(list) do
    case Keyword.keyword?(list) do
      true ->
        schema({:any, list}, opts)

      false ->
        schema({list, []}, opts)
    end
  end

  defp schema(value, opts)
       when not is_tuple(value),
       do: schema({value, []}, opts)

  defp schema({:ref, "#" <> _ = pointer}, _opts), do: Ref.new(pointer)

  defp schema({:ref, pointer}, opts) do
    uri = opts[:id] |> URI.parse() |> update_path(pointer)

    case String.ends_with?(uri.path, ".exon") do
      true ->
        case remote_schema(uri) do
          {:ok, schema} ->
            Ref.new(uri, schema)

          {:error, :not_found} ->
            raise SchemaError, message: "Schema '#{pointer}' not found."
        end

      false ->
        Ref.new(pointer)
    end
  end

  defp schema({list, keywords}, opts) when is_list(list),
    do:
      keywords
      |> Keyword.put(:type, list)
      |> update(opts)
      |> Schema.new()

  for type <- @schema_types do
    defp schema({unquote(type), keywords}, opts) when is_list(keywords) do
      keywords = Keyword.put(keywords, :type, unquote(type))
      {keywords, opts} = update_id(keywords, opts)

      case Validator.validate(unquote(type), keywords) do
        :ok -> keywords |> update(opts) |> Schema.new()
        {:error, msg} -> raise SchemaError, message: msg
      end
    end

    defp schema({unquote(type), _keywords}, _opts) do
      raise SchemaError,
        message: "Wrong argument for #{inspect(unquote(type))}."
    end
  end

  for keyword <- @schema_keywords do
    defp schema({unquote(keyword), keywords}, opts),
      do: schema({:any, [{unquote(keyword), keywords}]}, opts)
  end

  defp schema({bool, _}, _opts)
       when is_boolean(bool),
       do: Schema.new(type: bool)

  defp schema({type, _}, _opts) do
    raise SchemaError,
      message: "#{inspect(type)} is not a valid type or keyword."
  end

  defp update_path(uri, pointer) do
    path =
      case uri.path do
        nil ->
          Path.join("/", pointer)

        path ->
          if String.ends_with?(path, "/"),
            do: Path.join(path, pointer),
            else: Path.join("/", pointer)
      end

    Map.put(uri, :path, path) |> URI.to_string() |> URI.parse()
  end

  @spec update_id(keyword, keyword) :: {keyword, keyword}
  defp update_id(keywords, opts) do
    {kid, oid} = do_update_id(keywords[:id], opts[:id])

    {Keyword.put(keywords, :id, kid), Keyword.put(opts, :id, oid)}
  end

  defp do_update_id(nil, oid) do
    {nil, oid}
  end

  defp do_update_id("http" <> _ = kid, nil) do
    {kid, kid}
  end

  defp do_update_id(kid, "http" <> _ = oid) do
    id = oid |> URI.merge(kid) |> URI.to_string()
    {id, id}
  end

  defp do_update_id(kid, oid) do
    {kid, oid}
  end

  # function: update/1
  #
  @spec update(keyword, keyword) :: keyword
  defp update(keywords, opts) do
    keywords
    |> Keyword.put_new(:as, keywords[:type])
    |> Keyword.update(:additional_items, nil, &bool_or_schema(&1, opts))
    |> Keyword.update(:additional_properties, nil, &bool_or_schema(&1, opts))
    |> Keyword.update(:all_of, nil, &schemas(&1, opts))
    |> Keyword.update(:any_of, nil, &schemas(&1, opts))
    |> Keyword.update(:dependencies, nil, &dependencies(&1, opts))
    |> Keyword.update(:items, nil, &items(&1, opts))
    |> Keyword.update(:not, nil, &schema(&1, opts))
    |> Keyword.update(:one_of, nil, &schemas(&1, opts))
    |> Keyword.update(:pattern_properties, nil, &properties(&1, opts))
    |> Keyword.update(:properties, nil, &properties(&1, opts))
    |> Keyword.update(:definitions, nil, &properties(&1, opts))
    |> Keyword.update(:required, nil, &MapSet.new/1)
    |> update_allow()
  end

  @spec schemas(list, keyword) :: list
  defp schemas(list, opts),
    do: Enum.map(list, fn schema -> schema(schema, opts) end)

  @spec properties(map, keyword) :: map
  defp properties(map, opts),
    do: Enum.into(map, %{}, fn {key, prop} -> {key, schema(prop, opts)} end)

  @spec dependencies(map, keyword) :: map
  defp dependencies(map, opts),
    do:
      Enum.into(map, %{}, fn
        {key, dep} when is_list(dep) -> {key, dep}
        {key, dep} when is_boolean(dep) -> {key, schema(dep, opts)}
        {key, dep} when is_atom(dep) -> {key, [dep]}
        {key, dep} when is_binary(dep) -> {key, [dep]}
        {key, dep} -> {key, schema(dep, opts)}
      end)

  @spec bool_or_schema(boolean | atom, keyword) :: boolean | Xema.Schema.t()
  defp bool_or_schema(bool, _opts) when is_boolean(bool), do: bool

  defp bool_or_schema(schema, opts), do: schema(schema, opts)

  @spec items(any, keyword) :: list
  defp items(schema, opts) when is_atom(schema) or is_tuple(schema),
    do: schema(schema, opts)

  defp items(schemas, opts) when is_list(schemas), do: schemas(schemas, opts)

  defp items(items, _opts), do: items

  defp update_allow(opts) do
    case Keyword.get(opts, :allow, :undefined) do
      :undefined ->
        opts

      value ->
        Keyword.update!(opts, :type, fn
          types when is_list(types) -> [value | types]
          type -> [type, value]
        end)
    end
  end

  defp remote_schema(%URI{} = uri), do: remote_schema(URI.to_string(uri))

  defp remote_schema(uri) do
    with {:ok, str} <- get_remote(uri),
         {:ok, data} <- eval(str) do
      data =
        case data do
          type when is_atom(type) -> {type, id: uri}
          {type, keywords} -> {type, Keyword.put(keywords, :id, uri)}
          keywords -> Keyword.put(keywords, :id, uri)
        end

      {:ok, Xema.new(data)}
    else
      {:error, %SyntaxError{description: desc, line: line}} ->
        raise SyntaxError, description: desc, line: line, file: uri

      {:error, %CompileError{description: desc, line: line}} ->
        raise CompileError, description: desc, line: line, file: uri

      {:error, :not_found} ->
        raise SchemaError, message: "Remote schema '#{uri}' not found."
    end
  end

  defp get_remote(uri) do
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      error -> {:error, error}
    end
  end

  defp del_fragment(uri),
    do: uri |> URI.parse() |> Map.put(:fragment, nil) |> URI.to_string()

  defp eval(str) do
    {data, _} = Code.eval_string(str)
    {:ok, data}
  rescue
    error -> {:error, error}
  end

  #
  # to_string
  #
  @spec to_string(Xema.t(), keyword) :: String.t()
  def to_string(%Xema{} = xema, opts \\ []) do
    opts
    |> Keyword.get(:format, :call)
    |> do_to_string(xema.content)
  end

  @spec do_to_string(atom, Schema.t()) :: String.t()
  defp do_to_string(:call, schema),
    do: "Xema.new(#{schema_to_string(schema, true)})"

  defp do_to_string(:data, schema), do: "{#{schema_to_string(schema, true)}}"

  @spec schema_to_string(Schema.t() | atom, atom) :: String.t()
  defp schema_to_string(schema, root \\ false)

  defp schema_to_string(%Schema{type: type} = schema, root),
    do:
      do_schema_to_string(
        type,
        schema |> Schema.to_map() |> Map.delete(:type),
        root
      )

  defp schema_to_string(schema, _root),
    do:
      schema
      |> Enum.sort()
      |> Enum.map(&key_value_to_string/1)
      |> Enum.join(", ")

  defp do_schema_to_string(type, schema, _root) when schema == %{},
    do: inspect(type)

  defp do_schema_to_string(:any, schema, true) do
    case Map.to_list(schema) do
      [{key, value}] -> "#{inspect(key)}, #{value_to_string(value)}"
      _ -> ":any, #{schema_to_string(schema)}"
    end
  end

  defp do_schema_to_string(type, schema, true),
    do: "#{inspect(type)}, #{schema_to_string(schema)}"

  defp do_schema_to_string(type, schema, false),
    do: "{#{do_schema_to_string(type, schema, true)}}"

  @spec value_to_string(any) :: String.t()
  defp value_to_string(%Schema{} = schema), do: schema_to_string(schema)

  defp value_to_string(%{__struct__: MapSet} = map_set),
    do: value_to_string(MapSet.to_list(map_set))

  defp value_to_string(%{__struct__: Regex} = regex),
    do: ~s("#{Regex.source(regex)}")

  defp value_to_string(%{__struct__: Xema.Ref} = ref) do
    "#{ref}"
  end

  defp value_to_string(list) when is_list(list),
    do:
      list
      |> Enum.map(&value_to_string/1)
      |> Enum.join(", ")
      |> wrap("[", "]")

  defp value_to_string(map) when is_map(map),
    do:
      map
      |> Enum.map(&key_value_to_string/1)
      |> Enum.join(", ")
      |> wrap("%{", "}")

  defp value_to_string(value), do: inspect(value)

  @spec key_value_to_string({atom | String.t(), any}) :: String.t()
  defp key_value_to_string({:ref, %{__struct__: Xema.Ref} = ref}),
    do: "ref: #{inspect(ref.pointer)}"

  defp key_value_to_string({key, value}) when is_atom(key),
    do: "#{key}: #{value_to_string(value)}"

  defp key_value_to_string({%{__struct__: Regex} = regex, value}),
    do: key_value_to_string({Regex.source(regex), value})

  defp key_value_to_string({key, value}),
    do: ~s("#{key}" => #{value_to_string(value)})

  @spec wrap(String.t(), String.t(), String.t()) :: String.t()
  defp wrap(str, trailing, pending), do: "#{trailing}#{str}#{pending}"
end

defimpl String.Chars, for: Xema do
  @spec to_string(Xema.t()) :: String.t()
  def to_string(xema), do: Xema.to_string(xema)
end
