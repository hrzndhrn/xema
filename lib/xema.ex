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

  for type <- @schema_types do
    def init(unquote(type), keywords), do: schema({unquote(type), keywords}, [])
  end

  for keyword <- @schema_keywords do
    def init(unquote(keyword), keywords),
      do: init(:any, [{unquote(keyword), keywords}])
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
  defp schema(type, keywords \\ [])

  defp schema(list, keywords) when is_list(list) do
    case Keyword.keyword?(list) do
      true ->
        schema({:any, list}, keywords)

      false ->
        schema({list, []}, keywords)
    end
  end

  defp schema(value, keywords)
       when not is_tuple(value),
       do: schema({value, []}, keywords)

  defp schema({:ref, pointer}, _), do: Ref.new(pointer)

  defp schema({list, keywords}, _) when is_list(list),
    do:
      keywords
      |> Keyword.put(:type, list)
      |> update()
      |> Schema.new()

  for type <- @schema_types do
    defp schema({unquote(type), keywords}, _) when is_list(keywords) do
      keywords = Keyword.put(keywords, :type, unquote(type))

      case Validator.validate(unquote(type), keywords) do
        :ok -> keywords |> update() |> Schema.new()
        {:error, msg} -> raise SchemaError, message: msg
      end
    end

    defp schema({unquote(type), _keywords}, _) do
      raise SchemaError,
        message: "Wrong argument for #{inspect(unquote(type))}."
    end
  end

  for keyword <- @schema_keywords do
    defp schema({unquote(keyword), keywords}, _),
      do: schema({:any, [{unquote(keyword), keywords}]})
  end

  defp schema({bool, _}, _)
       when is_boolean(bool),
       do: Schema.new(type: bool)

  defp schema({type, _}, _) do
    raise SchemaError,
      message: "#{inspect(type)} is not a valid type or keyword."
  end

  # function: update/1
  #
  @spec update(keyword) :: keyword
  defp update(keywords) do
    keywords
    |> Keyword.put_new(:as, keywords[:type])
    |> Keyword.update(:additional_items, nil, &bool_or_schema/1)
    |> Keyword.update(:additional_properties, nil, &bool_or_schema/1)
    |> Keyword.update(:all_of, nil, &schemas/1)
    |> Keyword.update(:any_of, nil, &schemas/1)
    |> Keyword.update(:dependencies, nil, &dependencies/1)
    |> Keyword.update(:items, nil, &items/1)
    |> Keyword.update(:not, nil, &schema/1)
    |> Keyword.update(:one_of, nil, &schemas/1)
    |> Keyword.update(:pattern_properties, nil, &properties/1)
    |> Keyword.update(:properties, nil, &properties/1)
    |> Keyword.update(:definitions, nil, &properties/1)
    |> Keyword.update(:required, nil, &MapSet.new/1)
    |> update_allow()
  end

  @spec schemas(list) :: list
  defp schemas(list), do: Enum.map(list, fn schema -> schema(schema) end)

  @spec properties(map) :: map
  defp properties(map),
    do: Enum.into(map, %{}, fn {key, prop} -> {key, schema(prop)} end)

  @spec dependencies(map) :: map
  defp dependencies(map),
    do:
      Enum.into(map, %{}, fn
        {key, dep} when is_list(dep) -> {key, dep}
        {key, dep} when is_boolean(dep) -> {key, schema(dep)}
        {key, dep} when is_atom(dep) -> {key, [dep]}
        {key, dep} when is_binary(dep) -> {key, [dep]}
        {key, dep} -> {key, schema(dep)}
      end)

  @spec bool_or_schema(boolean | atom) :: boolean | Xema.Schema.t()
  defp bool_or_schema(bool) when is_boolean(bool), do: bool

  defp bool_or_schema(schema), do: schema(schema)

  @spec items(any) :: list
  defp items(schema) when is_atom(schema) or is_tuple(schema),
    do: schema(schema)

  defp items(schemas) when is_list(schemas), do: schemas(schemas)

  defp items(items), do: items

  defp update_allow(keywords) do
    case Keyword.get(keywords, :allow, :undefined) do
      :undefined ->
        keywords

      value ->
        Keyword.update!(keywords, :type, fn
          types when is_list(types) -> [value | types]
          type -> [type, value]
        end)
    end
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
    do: "ref: #{inspect(Ref.get_pointer(ref))}"

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
