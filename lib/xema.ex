defmodule Xema do
  @moduledoc """
  A schema validator inspired by [JSON Schema](http://json-schema.org).

  All available keywords to construct a schema are described on page
  [Usage](usage.html).

  This module can be used to construct a schema module. Should a module
  contain multiple schemas the option `multi: true` is required.

  `use Xema` imports `Xema.Builder` and extends the module with the functions
  + `__MODULE__.valid?/2`
  + `__MODULE__.validate/2`
  + `__MODULE__.validate!/2`
  + `__MODULE__.cast/2`
  + `__MODULE__.cast!/2`
  + `__MODULE__.xema/1`

  The macro `xema/2` supports the construction of a schema. After that
  the schema is available via the functions above.

  In a multi schema module a schema can be tagged with `@default true` and
  then called by
  + `__MODULE__.valid?/1`
  + `__MODULE__.validate/1`
  + `__MODULE__.validate!/1`
  + `__MODULE__.cast/1`
  + `__MODULE__.cast!/1`
  + `__MODULE__.xema/0`

  The functions with arity 1 are also available for single schema modules.

  ## Examples

  Sinlge schema module:

      iex> defmodule SingleSchema do
      ...>   use Xema
      ...>
      ...>   # The name :num is optional.
      ...>   xema :num, do: number(minimum: 1)
      ...> end
      iex>
      iex> SingleSchema.valid?(:num, 6)
      true
      iex> SingleSchema.valid?(5)
      true
      iex> SingleSchema.validate(0)
      {:error, %Xema.ValidationError{
         reason: %{minimum: 1, value: 0}
      }}
      iex> SingleSchema.cast("5")
      {:ok, 5}
      iex> SingleSchema.cast("-5")
      {:error, %Xema.ValidationError{
         reason: %{minimum: 1, value: -5}
      }}

  Multi schema module:

      iex> defmodule Schema do
      ...>   use Xema, multi: true
      ...>
      ...>   @pos integer(minimum: 0)
      ...>   @neg integer(maximum: 0)
      ...>
      ...>   @default true
      ...>   xema :user do
      ...>     map(
      ...>       properties: %{
      ...>         name: string(min_length: 1),
      ...>         age: @pos
      ...>       }
      ...>     )
      ...>   end
      ...>
      ...>   xema :nums do
      ...>     map(
      ...>       properties: %{
      ...>         pos: list(items: @pos),
      ...>         neg: list(items: @neg)
      ...>       }
      ...>     )
      ...>   end
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
      {:error, %Xema.ValidationError{
        reason: %{
          properties: %{name: %{min_length: 1, value: ""}}}
        }
      }
      iex> Schema.valid?(:nums, %{pos: [1, 2, 3]})
      true
      iex> Schema.valid?(:nums, %{neg: [1, 2, 3]})
      false
      ```

  Struct schema module:

      TODO: struct example
      iex> defmodule StructA do
      ...>   use Xema
      ...>
      ...>   xema do
      ...>     field :foo, :integer, minimum: 0
      ...>   end
      ...> end
      ...>
      ...> defmodule StructB do
      ...>   use Xema
      ...>
      ...>   xema do
      ...>     field :a, :string, min_length: 3
      ...>     field :b, StructA
      ...>     required [:a]
      ...>   end
      ...> end
      ...>
      ...> data = StructB.cast!(a: "abc", b: %{foo: 5})
      ...> data.a
      "abc"
      iex> Map.from_struct(data.b)
      %{foo: 5}

  """

  use Xema.Behaviour

  import Xema.Castable.Helper, only: [cast_key: 2]
  import Xema.Utils, only: [to_existing_atom: 1]

  alias Xema.{
    Castable,
    CastError,
    Ref,
    Schema,
    SchemaError,
    SchemaValidator,
    ValidationError
  }

  @keywords Schema.keywords()
  @types Schema.types()

  @doc false
  defmacro __using__(opts) do
    multi = Keyword.get(opts, :multi, false)

    quote do
      import Xema.Builder
      @xemas []
      @default false
      @multi unquote(multi)
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
      {:error, %Xema.ValidationError{
        reason: %{
          items: [{2, %{value: 1, minimum: 2}}]}
        }
      }

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

  # Creates a schema from an atom type.
  # This function will be just called for nested schemas.
  @spec schema(Schema.type(), keyword) :: Schema.t()
  defp schema(value, opts) when value in @types do
    schema({value, []}, opts)
  end

  # Creates a schema from a `Xema` module.
  @spec schema(atom, keyword) :: Schema.t()
  defp schema(value, _opts) when is_atom(value) do
    ensure_behaviour!(value).xema().schema
  end

  # Creates a bool schema. Keywords and opts will be ignored.
  @spec schema({Schema.type() | [Schema.type()], keyword}, keyword) :: Schema.t()
  defp schema({bool, _}, _) when is_boolean(bool), do: Schema.new(type: bool)

  # Creates a schema for a reference.
  defp schema({:ref, keywords}, _), do: schema({:any, [{:ref, keywords}]})

  defp schema({type, keywords}, _) do
    keywords
    |> Keyword.put(:type, type)
    |> update()
    |> Schema.new()
  end

  # This function creates the schema tree.
  @spec update(keyword) :: keyword
  defp update(keywords) do
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
  end

  @spec schemas(list) :: list
  defp schemas(list) when is_list(list), do: Enum.map(list, fn schema -> schema(schema) end)

  @spec schemas(map) :: map
  defp schemas(map) when is_map(map), do: map_values(map, &schema/1)

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

  defp maybe_schema({:ref, str} = ref) when is_binary(str), do: schema(ref)

  defp maybe_schema({atom, list} = tuple)
       when is_atom(atom) and is_list(list) do
    case atom in Schema.types() do
      true -> schema(tuple)
      false -> tuple
    end
  end

  defp maybe_schema(%_{} = struct), do: struct

  defp maybe_schema(map) when is_map(map), do: map_values(map, &maybe_schema/1)

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
  defp map_values(map, fun) when is_map(map) and is_function(fun),
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

  defp nested_source(%_{} = struct), do: struct

  defp nested_source(val) when is_map(val) do
    map_values(val, &nested_source/1)
  end

  defp nested_source(val) when is_list(val), do: Enum.map(val, &nested_source/1)

  defp nested_source(val), do: val

  @doc """
  Converts the given data using the specified schema. Returns the converted data
  or an exception.
  """
  @spec cast!(Xema.t(), term) :: term
  def cast!(xema, value, opts \\ []) do
    case cast(xema, value, opts) do
      {:ok, cast} ->
        cast

      {:error, exception} ->
        raise exception
    end
  end

  @doc """
  Converts the given data using the specified schema. Returns `{:ok, result}` or
  `{:error, reason}`. The `result` is converted and validated with the schema.

  ## Examples:

      iex> schema = Xema.new({:integer, minimum: 1})
      iex> Xema.cast(schema, "5")
      {:ok, 5}
      iex> Xema.cast(schema, "five")
      {:error, %Xema.CastError{
        key: nil,
        path: [],
        to: :integer,
        value: "five"
      }}
      iex> Xema.cast(schema, "0")
      {:error, %Xema.ValidationError{
        reason: %{minimum: 1, value: 0}
      }}

  ## Multiple types

  If for a value multiple types are defined the function used the result of the
  first successful conversion.

  ## Examples

      iex> schema = Xema.new([:integer, :string, nil])
      iex> Xema.cast(schema, 5)
      {:ok, 5}
      iex> Xema.cast(schema, 5.5)
      {:ok, "5.5"}
      iex> Xema.cast(schema, "5")
      {:ok, 5}
      iex> Xema.cast(schema, "five")
      {:ok, "five"}
      iex> Xema.cast(schema, nil)
      {:ok, nil}
      iex> Xema.cast(schema, [5])
      {:error,
        %Xema.CastError{path: [], to: [:integer, :string, nil], value: [5]}
      }

  ## Cast with `any_of`, `all_of`, and `one_of`

  Schemas in a combiner will be cast independently one by one in reverse order.

  ## Examples

      iex> schema = Xema.new(any_of: [
      ...>   [properties: %{a: :integer}],
      ...>   [properties: %{a: :string}]
      ...> ])
      iex> Xema.cast(schema, %{a: 5})
      {:ok, %{a: 5}}
      iex> Xema.cast(schema, %{a: 5.5})
      {:ok, %{a: "5.5"}}
      iex> Xema.cast(schema, %{a: "5"})
      {:ok, %{a: 5}}
      iex> Xema.cast(schema, %{a: "five"})
      {:ok, %{a: "five"}}
      iex> Xema.cast(schema, %{a: [5]})
      {:error,
        %Xema.CastError{
          error: nil,
          key: nil,
          message: nil,
          path: [],
          to: [
            %{path: [:a], to: :integer, value: [5]},
            %{path: [:a], to: :string, value: [5]}
          ],
          value: %{a: [5]}
      }}

  ## Options

  With the option `additional_properties: :delete` additional properties will be
  deleted on cast. Additional properties will be deleted in schemas with
  `additional_properties: false`.

  ## Examples

      iex> schema = Xema.new(
      ...>   properties: %{
      ...>     a: [
      ...>       properties: %{
      ...>         foo: :integer
      ...>       },
      ...>       additional_properties: false
      ...>     ],
      ...>     b: [
      ...>       properties: %{
      ...>         foo: :integer
      ...>       }
      ...>     ]
      ...>   }
      ...> )
      iex>
      iex> Xema.cast(schema, %{
      ...>   a: %{foo: "6", bar: "7"},
      ...>   b: %{foo: "6", bar: "7"},
      ...> }, additional_properties: :delete)
      {:ok, %{
        a: %{foo: 6},
        b: %{foo: 6, bar: "7"}
      }}
  """
  @spec cast(Xema.t(), term) :: {:ok, term} | {:error, term}
  def cast(%Xema{schema: schema}, value, opts \\ []) do
    with {:ok, result} <- do_cast(schema, value, opts, []),
         :ok <- validate(schema, result) do
      {:ok, result}
    else
      {:error, %ValidationError{}} = validation_error ->
        validation_error

      {:error, reason} ->
        {:error,
         CastError.exception(
           error: Map.get(reason, :error),
           key: Map.get(reason, :key),
           path: Map.get(reason, :path),
           required: Map.get(reason, :required),
           to: Map.get(reason, :to),
           value: Map.get(reason, :value)
         )}
    end
  end

  @spec do_cast(Schema.t(), term, keyword, list) :: {:ok, term} | {:error, term}
  defp do_cast(%Schema{} = schema, data, opts, path)
       when is_list(data) or is_tuple(data) or is_map(data) do
    with {:ok, values} <- cast_values(schema, data, opts, path),
         {:ok, cast} <- castable_cast(schema, values) do
      cast_combiner(schema, cast, opts, path)
    else
      {:error, reason} ->
        {:error, Map.put_new(reason, :path, Enum.reverse(path))}
    end
  end

  defp do_cast(%Schema{} = schema, value, opts, path) do
    case castable_cast(schema, value) do
      {:ok, cast} -> cast_combiner(schema, cast, opts, path)
      {:error, reason} -> {:error, Map.put(reason, :path, Enum.reverse(path))}
    end
  end

  defp do_cast(nil, value, _opts, _path), do: {:ok, value}

  @spec castable_cast(Schema.t(), term) :: {:ok, term} | {:error, term}
  defp castable_cast(%Schema{} = schema, value) do
    case do_castable_cast(schema, value) do
      {:ok, _} = ok ->
        ok

      {:error, _} = error ->
        error

      _ ->
        case schema do
          %{type: :struct, module: module} -> {:error, %{to: module, value: value}}
          %{type: type} -> {:error, %{to: type, value: value}}
        end
    end
  end

  defp do_castable_cast(%Schema{caster: caster}, value)
       when is_function(caster),
       do: caster.(value)

  defp do_castable_cast(%Schema{caster: {caster, fun}}, value)
       when is_atom(caster) and is_atom(fun),
       do: apply(caster, fun, [value])

  defp do_castable_cast(%Schema{caster: {caster, fun, args}}, value)
       when is_atom(caster) and is_atom(fun),
       do: apply(caster, fun, [value | args])

  defp do_castable_cast(%Schema{caster: caster}, value)
       when caster != nil and is_atom(caster),
       do: caster.cast(value)

  defp do_castable_cast(schema, value), do: Castable.cast(value, schema)

  @spec cast_values(Schema.t(), term, keyword, list) :: term
  defp cast_values(schema, tuple, opts, path) when is_tuple(tuple) do
    with {:ok, values} <- cast_values(schema, Tuple.to_list(tuple), opts, path) do
      {:ok, List.to_tuple(values)}
    end
  end

  defp cast_values(schema, %module{} = struct, opts, path) do
    with {:ok, values} <- cast_values(schema, Map.from_struct(struct), opts, path) do
      {:ok, struct!(module, values)}
    end
  end

  defp cast_values(%Schema{} = schema, data, opts, path) when is_list(data) do
    case Keyword.keyword?(data) do
      true -> cast_values_keyword(schema, data, opts, path)
      false -> cast_values_list(schema, data, opts, path)
    end
  end

  defp cast_values(
         %Schema{
           type: type,
           keys: keys,
           properties: properties,
           pattern_properties: pattern_properties,
           additional_properties: additional_properties
         } = schema,
         data,
         opts,
         path
       )
       when is_map(data) do
    keys = if type == :keyword, do: :atoms, else: keys

    with :ok <- check_required(schema, data, path) do
      data
      |> Enum.reduce_while([], fn {key, value}, acc ->
        schema =
          get_properties_schema(
            properties,
            pattern_properties,
            additional_properties,
            key_to(keys, key)
          )

        case do_cast(schema, value, opts, [key | path]) do
          {:ok, cast} -> {:cont, [{key, cast} | acc]}
          {:error, _} = error -> {:halt, error}
        end
      end)
      |> case do
        {:error, _} = error ->
          error

        values ->
          {:ok,
           values
           |> delete_additional_properties(schema, opts)
           |> Enum.into(%{})
           |> add_defaults(schema, opts)}
      end
    end
  end

  @spec cast_values_keyword(Schema.t(), term, keyword, list) :: term
  defp cast_values_keyword(
         %Schema{
           keys: keys,
           properties: properties,
           pattern_properties: pattern_properties,
           additional_properties: additional_properties
         } = schema,
         data,
         opts,
         path
       )
       when is_list(data) do
    with :ok <- check_required(schema, data, path) do
      data
      |> Enum.reduce_while([], fn {key, value}, acc ->
        schema =
          get_properties_schema(
            properties,
            pattern_properties,
            additional_properties,
            key_to(keys, key)
          )

        case do_cast(schema, value, opts, [key | path]) do
          {:ok, cast} -> {:cont, [{key, cast} | acc]}
          {:error, _} = error -> {:halt, error}
        end
      end)
      |> case do
        {:error, _} = error ->
          error

        values ->
          {:ok,
           values
           |> delete_additional_properties(schema, opts)
           |> add_defaults(schema, opts)
           |> Enum.reverse()}
      end
    end
  end

  @spec cast_values_list(Schema.t(), term, keyword, list) :: term
  defp cast_values_list(%Schema{items: items} = schema, data, opts, path) when is_list(data) do
    case items do
      nil ->
        {:ok, data}

      %Schema{} = schema ->
        data
        |> Enum.with_index()
        |> Enum.reduce_while([], fn {item, index}, acc ->
          case do_cast(schema, item, opts, [index | path]) do
            {:ok, cast} -> {:cont, [cast | acc]}
            {:error, _} = error -> {:halt, error}
          end
        end)
        |> case do
          {:error, _} = error -> error
          values -> {:ok, Enum.reverse(values)}
        end

      items ->
        additional_items = Map.get(schema, :additional_items)

        data
        |> Enum.with_index()
        |> Enum.reduce_while([], fn {item, index}, acc ->
          schema = Enum.at(items, index, additional_items)

          case do_cast(schema, item, opts, [index | path]) do
            {:ok, cast} -> {:cont, [cast | acc]}
            {:error, _} = error -> {:halt, error}
          end
        end)
        |> case do
          {:error, _} = error -> error
          values -> {:ok, Enum.reverse(values)}
        end
    end
  end

  @spec check_required(Schema.t(), term, list) :: :ok | {:error, [String.t()] | [:atom]}
  defp check_required(%Schema{required: nil}, _data, _path), do: :ok

  defp check_required(
         %Schema{type: type, module: module, keys: keys, required: required},
         data,
         path
       ) do
    with {:error, keys} <- do_check_required(required, data, keys) do
      to = if module == nil, do: type, else: module
      {:error, %{to: to, value: data, required: keys, path: path}}
    end
  end

  defp do_check_required(required, data, keys_type) do
    keys =
      data
      |> keys()
      |> cast_keys(keys_type)
      |> MapSet.new()

    required
    |> MapSet.difference(keys)
    |> MapSet.to_list()
    |> case do
      [] -> :ok
      keys -> {:error, keys}
    end
  end

  @spec cast_keys([String.t()] | [atom], :strings | :atoms) :: [String.t()] | [atom]
  defp cast_keys(keys, keys_type) do
    Enum.map(keys, fn key ->
      case cast_key(key, keys_type) do
        :error -> key
        {:ok, cast} -> cast
      end
    end)
  end

  # additional_properties false will be ignored
  defp get_properties_schema(properties, pattern_properties, false, key),
    do: get_properties_schema(properties, pattern_properties, nil, key)

  defp get_properties_schema(nil, nil, additional_properties, _key), do: additional_properties

  defp get_properties_schema(properties, nil, additional_properties, key),
    do: Map.get(properties, key, additional_properties)

  defp get_properties_schema(nil, pattern_properties, additional_properties, key) do
    Enum.find_value(pattern_properties, additional_properties, fn {regex, schema} ->
      with true <- Regex.match?(regex, to_string(key)), do: schema
    end)
  end

  defp get_properties_schema(properties, pattern_properties, additional_properties, key) do
    get_properties_schema(properties, nil, additional_properties, key) ||
      get_properties_schema(nil, pattern_properties, additional_properties, key)
  end

  defp delete_additional_properties(data, %Schema{additional_properties: false} = schema, opts) do
    case Keyword.get(opts, :additional_properties) do
      :delete ->
        keys = Map.keys(Map.get(schema, :properties) || %{})
        patterns = Map.keys(Map.get(schema, :pattern_properties) || %{})
        Enum.filter(data, fn {key, _} -> key?(key, keys, patterns) end)

      _ ->
        data
    end
  end

  defp delete_additional_properties(data, _schema, _opts), do: data

  defp add_defaults(data, schema, _opts) do
    schema
    |> get_defaults()
    |> merge_defaults(data)
  end

  defp get_defaults(%Schema{properties: nil}), do: %{}

  defp get_defaults(%Schema{properties: properties}) do
    Enum.reduce(properties, %{}, fn
      {_key, %Schema{default: nil}}, acc ->
        acc

      {key, %Schema{default: default}}, acc ->
        Map.put(acc, key, get_default(default))
    end)
  end

  defp get_default(fun) when is_function(fun), do: apply(fun, [])

  defp get_default({mod, fun})
       when is_atom(mod) and is_atom(fun),
       do: apply(mod, fun, [])

  defp get_default({mod, fun, arg})
       when is_atom(mod) and is_atom(fun) and is_list(arg),
       do: apply(mod, fun, arg)

  defp get_default(value), do: value

  defp merge_defaults(defaults, data) when defaults == %{}, do: data

  defp merge_defaults(defaults, data) when is_map(data) do
    Enum.reduce(defaults, data, fn {key, value}, acc ->
      case {Map.get(acc, key), Map.get(acc, to_string(key))} do
        {nil, nil} -> Map.put(acc, key, value)
        _ -> acc
      end
    end)
  end

  defp merge_defaults(defaults, data) when is_list(data) do
    Enum.reduce(defaults, data, fn {key, value}, acc ->
      case Keyword.get(data, key) do
        nil -> Keyword.put(acc, key, value)
        _ -> acc
      end
    end)
  end

  defp key?(key, keys, []), do: key in keys

  defp key?(key, [], patterns),
    do: Enum.find_value(patterns, false, fn regex -> Regex.match?(regex, to_string(key)) end)

  defp key?(key, keys, patterns), do: key?(key, keys, []) && key?(key, [], patterns)

  defp cast_combiner(schema, data, opts, path),
    do:
      schema
      |> get_combiner()
      |> do_cast_combiner(data, opts, path)

  defp do_cast_combiner([], data, _opts, _path), do: {:ok, data}

  defp do_cast_combiner(schemas, data, opts, path) do
    schemas
    |> Enum.reverse()
    |> Enum.reduce({data, []}, fn schema, {data, errors} ->
      case do_cast(schema, data, opts, []) do
        {:ok, cast} -> {cast, errors}
        {:error, error} -> {data, [error | errors]}
      end
    end)
    |> case do
      {data, errors} when length(errors) < length(schemas) ->
        {:ok, data}

      {_, errors} ->
        {:error,
         %{
           to: errors,
           value: data,
           path: Enum.reverse(path)
         }}
    end
  end

  @spec get_combiner(Schema.t()) :: [Schema.t()]
  defp get_combiner(%Schema{} = schema),
    do: Enum.concat([schema.any_of || [], schema.all_of || [], schema.one_of || []])

  defp key_to(:atoms, key) when is_binary(key), do: to_existing_atom(key)

  defp key_to(:strings, key) when is_atom(key), do: to_string(key)

  defp key_to(_, key) when is_binary(key) or is_atom(key), do: key

  defp keys(data) when is_map(data), do: Map.keys(data)

  defp keys(data) when is_list(data), do: Keyword.keys(data)

  @doc false
  def ensure_behaviour!(name) when is_atom(name) do
    case behaviour?(name) do
      true -> name
      false -> raise SchemaError, message: "Module #{inspect(name)} is not a Xema behaviour"
    end
  end

  @doc false
  def behaviour?(name) when is_atom(name) do
    module =
      case Code.ensure_compiled(name) do
        {:module, module} -> module
        {:error, _} -> raise SchemaError, message: "Module #{inspect(name)} not compiled"
      end

    function_exported?(module, :xema, 0)
  end
end
