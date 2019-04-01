defmodule Xema do
  @moduledoc """
  A schema validator inspired by [JSON Schema](http://json-schema.org).

  All available keywords to construct a schema are described on page
  [Usage](usage.html).

  This module can be used to construct a schema module.

  `use Xema` imports `Xema.Builder` and extends the module with the functions
  + `__MODULE__.valid?/2`
  + `__MODULE__.validate/2`
  + `__MODULE__.validate!/2`

  The macro `xema/2` supports the construction of a schema. After that
  the schema is available as a function.

  A schema can also be tagged with `@default true` and then called by
  + `__MODULE__.valid?/1`
  + `__MODULE__.validate/1`
  + `__MODULE__.validate!/1`

  ## Example

  ```elixir
  iex> defmodule Schema do
  ...>   use Xema
  ...>
  ...>   @pos integer(minimum: 0)
  ...>   @neg integer(maximum: 0)
  ...>
  ...>   @default true
  ...>   xema :user,
  ...>        map(
  ...>          properties: %{
  ...>            name: string(min_length: 1),
  ...>            age: @pos
  ...>          }
  ...>        )
  ...>
  ...>   xema :nums,
  ...>        map(
  ...>          properties: %{
  ...>            pos: list(items: @pos),
  ...>            neg: list(items: @neg)
  ...>          }
  ...>        )
  ...> end
  iex>
  iex> Schema.valid?(:user, %{name: "John", age: 21})
  true
  iex> Schema.valid?(%{name: "John", age: 21})
  true
  iex> Schema.valid?(%{name: "", age: 21})
  false
  iex> Schema.validate(%{name: "John", age: 21})
  :ok
  iex> Schema.validate(%{name: "", age: 21})
  {:error, %{properties: %{name: %{min_length: 1, value: ""}}}}
  iex> Schema.valid?(:nums, %{pos: [1, 2, 3]})
  true
  iex> Schema.valid?(:nums, %{neg: [1, 2, 3]})
  false
  ```
  """

  use Xema.Behaviour

  alias Xema.Castable
  alias Xema.CastError
  alias Xema.Ref
  alias Xema.Schema
  alias Xema.SchemaValidator

  @keywords Schema.keywords()
  @types Schema.types()

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Xema.Builder
      @xemas []
      @default false
    end
  end

  @doc """
  This function creates the schema from the given `data`.

  Possible options:
  + `:loader` - a loader for remote schemas. This option will overwrite the
                loader from the config.
                See [Configure a loader](loader.html) to how to define a loader.

  + `inline` - inlined all references in the schema. Default `:true`.

  ## Examples

  Simple schema:

      iex> schema = Xema.new :string
      iex> Xema.valid? schema, "hello"
      true
      iex> Xema.valid? schema, 42
      false

  Schema:

      iex> schema = Xema.new {:string, min_length: 3, max_length: 12}
      iex> Xema.valid? schema, "hello"
      true
      iex> Xema.valid? schema, "hi"
      false

  Nested schemas:

      iex> schema = Xema.new {:list, items: {:number, minimum: 2}}
      iex> Xema.validate(schema, [2, 3, 4])
      :ok
      iex> Xema.valid?(schema, [2, 3, 4])
      true
      iex> Xema.validate(schema, [2, 3, 1])
      {:error, %{items: [{2, %{value: 1, minimum: 2}}]}}

  More examples can be found on page
  [Usage](https://hexdocs.pm/xema/usage.html#content).
  """
  @spec new(Schema.t() | Schema.type() | tuple | atom | keyword, keyword) ::
          Xema.t()
  def new(data, opts)

  # The implementation of `init`.
  #
  # This function prepares the given keyword list for the function schema.
  @impl true
  @doc false
  @spec init(atom | keyword | {atom | [atom], keyword}) :: Schema.t()
  def init(type) when is_atom(type), do: init({type, []})

  def init(val) when is_list(val) do
    case Keyword.keyword?(val) do
      true ->
        # init without a given type
        init({:any, val})

      false ->
        # init with multiple types
        init({val, []})
    end
  end

  def init({:ref, pointer}), do: init({:any, ref: pointer})

  def init(data) do
    SchemaValidator.validate!(data)
    schema(data)
  end

  # This function creates a schema from the given data.
  defp schema(type, opts \\ [])

  # Extracts the schema form a `%Xema{}` struct.
  # This function will be just called for nested schemas.
  @spec schema(Xema.t(), keyword) :: Schema.t()
  defp schema(%Xema{schema: schema}, _), do: schema

  # Creates a schema from a list. Expected a list of types or a keyword list
  # for an any schema.
  # This function will be just called for nested schemas.
  @spec schema([Schema.type()] | keyword, keyword) :: Schema.t()
  defp schema(list, opts) when is_list(list) do
    case Keyword.keyword?(list) do
      true ->
        schema({:any, list}, opts)

      false ->
        schema({list, []}, opts)
    end
  end

  # Creates a schema from an atom.
  # This function will be just called for nested schemas.
  @spec schema(Schema.type(), keyword) :: Schema.t()
  defp schema(value, opts)
       when is_atom(value),
       do: schema({value, []}, opts)

  # Creates a bool schema. Keywords and opts will be ignored.
  @spec schema({Schema.type() | [Schema.type()], keyword}, keyword) ::
          Schema.t()
  defp schema({bool, _}, _) when is_boolean(bool), do: Schema.new(type: bool)

  # Creates a schema for a reference.
  defp schema({:ref, keywords}, _), do: schema({:any, [{:ref, keywords}]})

  defp schema({type, keywords}, _),
    do:
      keywords
      |> Keyword.put(:type, type)
      |> update()
      |> Schema.new()

  # This function creates the schema tree.
  @spec update(keyword) :: keyword
  defp update(keywords),
    do:
      keywords
      |> Keyword.update(:additional_items, nil, &bool_or_schema/1)
      |> Keyword.update(:additional_properties, nil, &bool_or_schema/1)
      |> Keyword.update(:all_of, nil, &schemas/1)
      |> Keyword.update(:any_of, nil, &schemas/1)
      |> Keyword.update(:contains, nil, &schema/1)
      |> Keyword.update(:dependencies, nil, &dependencies/1)
      |> Keyword.update(:else, nil, &schema/1)
      |> Keyword.update(:if, nil, &schema/1)
      |> Keyword.update(:items, nil, &items/1)
      |> Keyword.update(:not, nil, &schema/1)
      |> Keyword.update(:one_of, nil, &schemas/1)
      |> Keyword.update(:pattern_properties, nil, &schemas/1)
      |> Keyword.update(:properties, nil, &schemas/1)
      |> Keyword.update(:property_names, nil, &schema/1)
      |> Keyword.update(:definitions, nil, &schemas/1)
      |> Keyword.update(:required, nil, &MapSet.new/1)
      |> Keyword.update(:then, nil, &schema/1)
      |> update_allow()
      |> update_data()

  @spec schemas(list) :: list
  defp schemas(list) when is_list(list),
    do: Enum.map(list, fn schema -> schema(schema) end)

  @spec schemas(map) :: map
  defp schemas(map) when is_map(map),
    do: map_values(map, &schema/1)

  @spec dependencies(map) :: map
  defp dependencies(map),
    do:
      Enum.into(map, %{}, fn
        {key, dep} when is_list(dep) ->
          case Keyword.keyword?(dep) do
            true -> {key, schema(dep)}
            false -> {key, dep}
          end

        {key, dep} when is_boolean(dep) ->
          {key, schema(dep)}

        {key, dep} when is_atom(dep) ->
          {key, [dep]}

        {key, dep} when is_binary(dep) ->
          {key, [dep]}

        {key, dep} ->
          {key, schema(dep)}
      end)

  @spec bool_or_schema(boolean | atom) :: boolean | Schema.t()
  defp bool_or_schema(bool) when is_boolean(bool), do: bool

  defp bool_or_schema(schema), do: schema(schema)

  @spec items(any) :: list
  defp items(schema) when is_atom(schema) or is_tuple(schema),
    do: schema(schema)

  defp items(value) when is_list(value) do
    case Keyword.keyword?(value) do
      true ->
        case schemas?(value) do
          true -> schemas(value)
          false -> schema(value)
        end

      false ->
        schemas(value)
    end
  end

  defp items(items), do: items

  @spec schemas?(keyword) :: boolean
  defp schemas?(value),
    do:
      value
      |> Keyword.keys()
      |> Enum.all?(fn type -> type in [:ref | @types] end)

  defp update_allow(keywords) do
    case Keyword.pop(keywords, :allow, :undefined) do
      {:undefined, keywords} ->
        keywords

      {value, keywords} ->
        Keyword.update!(keywords, :type, fn
          types when is_list(types) -> [value | types]
          type -> [type, value]
        end)
    end
  end

  defp update_data(keywords) do
    {data, keywords} = do_update_data(keywords)

    data =
      case Enum.empty?(data) do
        true -> nil
        false -> data
      end

    Keyword.put(keywords, :data, data)
  end

  @spec do_update_data(keyword) :: {map, keyword}
  defp do_update_data(keywords),
    do:
      keywords
      |> diff_keywords()
      |> Enum.reduce({%{}, keywords}, fn key, {data, keywords} ->
        {value, keywords} = Keyword.pop(keywords, key)
        {Map.put(data, key, maybe_schema(value)), keywords}
      end)

  defp maybe_schema(list) when is_list(list) do
    case Keyword.keyword?(list) do
      true ->
        case has_keyword?(list) do
          true -> schema(list)
          false -> list
        end

      false ->
        Enum.map(list, &maybe_schema/1)
    end
  end

  defp maybe_schema(atom) when is_atom(atom) do
    case atom in Schema.types() do
      true -> schema(atom)
      false -> atom
    end
  end

  defp maybe_schema({:ref, str} = ref) when is_binary(str),
    do: schema(ref)

  defp maybe_schema({atom, list} = tuple)
       when is_atom(atom) and is_list(list) do
    case atom in Schema.types() do
      true -> schema(tuple)
      false -> tuple
    end
  end

  defp maybe_schema(%{__struct__: _} = struct), do: struct

  defp maybe_schema(map) when is_map(map),
    do: map_values(map, &maybe_schema/1)

  defp maybe_schema(value), do: value

  defp diff_keywords(list),
    do:
      list
      |> Keyword.keys()
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(@keywords))
      |> MapSet.to_list()

  defp has_keyword?(list),
    do:
      list
      |> Keyword.keys()
      |> MapSet.new()
      |> MapSet.disjoint?(MapSet.new(@keywords))
      |> Kernel.not()

  # Returns a map where each value is the result of invoking `fun` on each
  # value of the given `map`.
  @spec map_values(map, (any -> any)) :: map
  defp map_values(map, fun)
       when is_map(map) and is_function(fun),
       do: Enum.into(map, %{}, fn {key, val} -> {key, fun.(val)} end)

  @doc """
  Returns the source for a given `xema`. The output can differ from the input
  if the schema contains references. To get the original source the schema
  must be created with `inline: false`.

  ## Examples

      iex> {:integer, minimum: 1} |> Xema.new() |> Xema.source()
      {:integer, minimum: 1}
  """
  @spec source(Xema.t() | Schema.t()) :: atom | keyword | {atom, keyword}
  def source(%Xema{} = xema), do: source(xema.schema)

  def source(%Schema{} = schema) do
    type = schema.type
    data = Map.get(schema, :data) || %{}

    keywords =
      schema
      |> Schema.to_map()
      |> Map.delete(:type)
      |> Map.delete(:data)
      |> Map.merge(data)
      |> Enum.map(fn {key, val} -> {key, nested_source(val)} end)
      |> map_ref()

    case {type, keywords} do
      {type, []} -> type
      {:any, keywords} -> keywords
      tuple -> tuple
    end
  end

  defp map_ref(keywords) do
    case Keyword.has_key?(keywords, :ref) do
      true ->
        if length(keywords) == 1 do
          keywords[:ref]
        else
          {_, pointer} = keywords[:ref]
          Keyword.put(keywords, :ref, pointer)
        end

      false ->
        keywords
    end
  end

  defp nested_source(%Schema{} = val), do: source(val)

  defp nested_source(%Ref{} = val), do: {:ref, val.pointer}

  defp nested_source(%MapSet{} = val), do: Map.keys(val.map)

  defp nested_source(%{__struct__: _} = val), do: val

  defp nested_source(val)
       when is_map(val),
       do: map_values(val, &nested_source/1)

  defp nested_source(val)
       when is_list(val),
       do: Enum.map(val, &nested_source/1)

  defp nested_source(val), do: val

  @doc """
  Converts the given data using the specified schema. Returns the `result}` or an exception.
  """
  @spec cast(Xema.t(), term) :: term
  def cast!(xema, value) do
    with {:ok, cast} <- cast(xema, value) do
      cast
    else
      {:error, exception} ->
        raise exception
    end
  end

  @doc """
  Converts the given data using the specified schema. Returns `{:ok, result}` or
  `{:error, reason}`.
  """
  @spec cast(Xema.t(), term) :: {:ok, term} | {:error, term}
  def cast(%Xema{schema: schema}, value) do
    do_cast(schema, value, [])
  catch
    {:error, %{path: path} = reason} ->
      {:error, CastError.exception(%{reason | path: Enum.reverse(path)})}
  end

  @spec do_cast(Schema.t(), term, list) :: {:ok, term} | {:error, term}
  defp do_cast(%Schema{} = schema, map, path) when is_map(map) do
    with {:ok, cast} <- Castable.cast(map, schema) do
      cast_values(schema, cast, path)
    else
      {:error, reason} ->
        throw({:error, Map.put(reason, :path, path)})
    end
  end

  defp do_cast(%Schema{} = schema, list, path) when is_list(list) or is_tuple(list) do
    with {:ok, cast} <- Castable.cast(list, schema) do
      cast_values(schema, cast, path)
    else
      {:error, reason} ->
        throw({:error, Map.put(reason, :path, path)})
    end
  end

  defp do_cast(%Schema{} = schema, value, path) do
    with {:ok, cast} <- Castable.cast(value, schema) do
      {:ok, cast}
    else
      {:error, reason} ->
        throw({:error, Map.put(reason, :path, path)})
    end
  end

  defp do_cast(nil, value, _), do: {:ok, value}

  @spec cast_values(Schema.t(), term, list) :: {:ok, term} | {:error, term}
  defp cast_values(%Schema{properties: nil}, map, _) when is_map(map), do: {:ok, map}

  defp cast_values(%Schema{properties: properties}, map, path) when is_map(map),
    do:
      {:ok,
       Enum.into(map, %{}, fn {key, value} ->
         with {:ok, cast} <- do_cast(Map.get(properties, key), value, [key | path]) do
           {key, cast}
         else
           {:error, reason} ->
             throw({:error, Map.put(reason, :path, [key | path])})
         end
       end)}

  defp cast_values(%Schema{type: :keyword, properties: nil}, list, _) when is_list(list),
    do: {:ok, list}

  defp cast_values(%Schema{properties: properties}, list, path)
       when is_list(list) and is_map(properties) do
    case Keyword.keyword?(list) do
      false ->
        {:ok, list}

      true ->
        {:ok,
         Enum.map(list, fn {key, value} ->
           with {:ok, cast} <- do_cast(Map.get(properties, key), value, [key | path]) do
             {key, cast}
           else
             {:error, reason} ->
               throw({:error, Map.put(reason, :path, [key | path])})
           end
         end)}
    end
  end

  defp cast_values(%Schema{items: nil}, tuple, _path) when is_tuple(tuple), do: {:ok, tuple}

  defp cast_values(%Schema{items: nil}, list, _path) when is_list(list), do: {:ok, list}

  defp cast_values(%Schema{items: items}, list, path) when is_list(list) and is_list(items) do
    result =
      list
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        case Enum.at(items, index) do
          nil ->
            value

          schema ->
            with {:ok, cast} <- do_cast(schema, value, [index | path]) do
              cast
            else
              {:error, reason} ->
                throw({:error, Map.put(reason, :path, [index | path])})
            end
        end
      end)

    {:ok, result}
  end

  defp cast_values(%Schema{items: items}, list, path) when is_list(list) do
    result =
      list
      |> Enum.with_index()
      |> Enum.map(fn {value, index} ->
        with {:ok, cast} <- do_cast(items, value, [index | path]) do
          cast
        else
          {:error, reason} ->
            throw({:error, Map.put(reason, :path, [index | path])})
        end
      end)

    {:ok, result}
  end

  defp cast_values(schema, tuple, path) when is_tuple(tuple) do
    {:ok, result} = cast_values(schema, Tuple.to_list(tuple), path)
    {:ok, List.to_tuple(result)}
  end
end
