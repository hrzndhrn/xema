defmodule Xema.Schema do
  @moduledoc """
  This module contains the struct for the keywords of a schema.
  """

  alias Xema.{Behaviour, Ref, Schema, SchemaError, Utils}

  @type xema :: struct

  @typedoc """
  The struct contains the keywords for a schema.

  * `additional_items` disallow additional items, if set to false. The keyword
    can also contain a schema to specify the type of additional items.
  * `additional_properties` disallow additional properties, if set to true.
  * 'all_of' a list of schemas they must all be valid.
  * 'any_of' a list of schemas with any valid schema.
  * `caster` a custom caster. This can be a function, a tuple with
    module and function name, or a `Xema.Caster` behaviour.
  * `comment` for the schema.
  * `const` specifies a constant.
  * `content_encoding` annotation for the encoding.
  * `content_media_type` annotation for the media type.
  * `contains` validates a list whether any item is valid for the given schema.
  * `data` none schema data. Values in `data` will be interpreted as schemas
    when possible. It is not recommended to put any data or schemas under this
    key. The `data` property is mainly for compatibility with JsonSchema.
  * `default` this keyword can be used to supply a default value for JSON and
    `defstruct`.
  * `definitions` contains schemas for reuse.
  * `dependencies` allows the schema of the map to change based on the presence
    of certain special properties
  * `description` of the schema.
  * `else` see `if`, `then`, `else`.
  * `enum` specifies an enumeration
  * `examples` the value of this keyword must be an array. There are no
    restrictions placed on the values within the array.
  * `exclusive_maximum` is a boolean. When true, it indicates that the range
    excludes the maximum value.
  * `exclusive_minimum` is a boolean. When true, it indicates that the range
    excludes the minimum value.
  * `format` semantic validation.
  * `id` a unique identifier.
  * `if`, `then`, `else`: These keywords work together to implement conditional
    application of a subschema based on the outcome of another subschema.
  * `items` specifies the type(s) of the items.
  * `keys` could be `:atoms` or `:strings`.
  * `max_items` the maximum length of list.
  * `max_length` the maximum length of string.
  * `max_properties` the maximum count of properties for the map.
  * `maximum` the maximum value.
  * `min_items` the minimal length of list.
  * `min_length` the minimal length of string.
  * `min_properties` the minimal count of properties for the map.
  * `minimum` the minimum value.
  * `module` the module of a struct.
  * `multiple_of` is a number greater 0. The value has to be a multiple of this
    number.
  * `not` negates the given schema
  * `one_of` the given data must be valid against exactly one of the given
    subschemas.
  * `pattern_properties` specifies schemas for properties by patterns
  * `pattern` restrict a string to a particular regular expression.
  * `properties` specifies schemas for properties.
  * `property_names` a schema to check property names.
  * `ref` a reference to a schema.
  * `required` contains a set of required properties.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `then` see `if`, `then`, `else`
  * `type` specifies the data type for a schema.
  * `unique_items` disallow duplicate items, if set to true.
  * `validator` a custom validator. This can be a function, a tuple with
    module and function name, or a `Xema.Validator` behaviour.
  """
  @type t :: %__MODULE__{
          additional_items: Behaviour.t() | Schema.t() | boolean | nil,
          additional_properties: map | boolean | nil,
          all_of: [Schema.t()] | nil,
          any_of: [Schema.t()] | nil,
          caster: function | module | {module, atom} | {module, atom, arity} | list | nil,
          comment: String.t() | nil,
          const: any,
          content_encoding: String.t() | nil,
          content_media_type: String.t() | nil,
          contains: Behaviour.t() | Schema.t() | nil,
          data: map | nil,
          default: any,
          definitions: map | nil,
          dependencies: list | map | nil,
          description: String.t() | nil,
          else: Behaviour.t() | Schema.t() | nil,
          enum: list | nil,
          examples: [any] | nil,
          exclusive_maximum: boolean | number | nil,
          exclusive_minimum: boolean | number | nil,
          format: atom | nil,
          id: String.t() | nil,
          if: Behaviour.t() | Schema.t() | nil,
          items: list | Behaviour.t() | Schema.t() | nil,
          keys: atom | nil,
          max_items: pos_integer | nil,
          max_length: pos_integer | nil,
          max_properties: pos_integer | nil,
          maximum: number | nil,
          min_items: pos_integer | nil,
          min_length: pos_integer | nil,
          min_properties: pos_integer | nil,
          minimum: number | nil,
          module: atom | nil,
          multiple_of: number | nil,
          not: Schema.t() | nil,
          one_of: [Schema.t()] | nil,
          pattern: Regex.t() | nil,
          pattern_properties: map | nil,
          properties: map | nil,
          property_names: Behaviour.t() | Schema.t() | nil,
          ref: Ref.t() | nil,
          required: MapSet.t() | nil,
          schema: String.t() | nil,
          then: Behaviour.t() | Schema.t() | nil,
          title: String.t() | nil,
          type: type | [type],
          unique_items: boolean | nil,
          validator: function | module | {module, atom} | {module, atom, arity} | list | nil
        }

  defstruct [
    :additional_items,
    :additional_properties,
    :all_of,
    :any_of,
    :caster,
    :comment,
    :const,
    :content_encoding,
    :content_media_type,
    :contains,
    :data,
    :default,
    :definitions,
    :dependencies,
    :description,
    :else,
    :enum,
    :examples,
    :exclusive_maximum,
    :exclusive_minimum,
    :format,
    :id,
    :if,
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
    :module,
    :multiple_of,
    :not,
    :one_of,
    :pattern,
    :pattern_properties,
    :properties,
    :property_names,
    :ref,
    :required,
    :schema,
    :then,
    :title,
    :unique_items,
    :validator,
    type: :any
  ]

  @typedoc """
  The `type` for the schema.
  """
  @type type ::
          :any
          | :atom
          | :boolean
          | false
          | :float
          | :integer
          | :keyword
          | :list
          | :map
          | nil
          | :number
          | :string
          | :struct
          | true
          | :tuple

  @types [
    :any,
    :atom,
    :boolean,
    false,
    :float,
    :integer,
    :keyword,
    :list,
    :map,
    nil,
    :number,
    :string,
    :struct,
    true,
    :tuple
  ]

  @doc """
  Returns a `%Schema{}` for the given `keywords` in the keyword list.
  """
  @spec new(keyword) :: Schema.t()
  def new(keywords),
    do:
      struct!(
        Schema,
        keywords |> validate_type!() |> update()
      )

  @doc """
  Returns the `%Schema{}` as a map. Items which a `nil` value are not in the
  map.
  """
  @spec to_map(Schema.t()) :: map
  def to_map(schema),
    do:
      schema
      |> Map.from_struct()
      |> delete_nils()

  @doc """
  Returns all available `type`s in a list.
  """
  @spec types :: [type]
  def types, do: @types

  @doc """
  Returns all keywords in a list.

  The key `:data` is not a regular keyword and is not in the list.
  """
  @spec keywords :: [atom]
  def keywords,
    do:
      %Schema{}
      |> Map.keys()
      |> List.delete(:data)
      |> List.delete(:__struct__)

  @doc """
  Fetches a subschema from the `schema` by the given `pointer`.

  If `schema` contains the given pointer with a subschema, then `{:ok, schema}`
  is returned otherwise `:error`.
  """
  @spec fetch(Schema.t(), Ref.t() | String.t()) :: {:ok, Schema.t()} | :error
  def fetch(%Schema{} = schema, "#/" <> pointer), do: fetch(schema, pointer)

  def fetch(%Schema{} = schema, pointer) do
    keys = pointer |> String.trim("/") |> String.split("/")

    do_fetch(schema, keys)
  end

  defp do_fetch(nil, _), do: :error

  defp do_fetch(:error, _), do: :error

  defp do_fetch(schema, []), do: {:ok, schema}

  defp do_fetch(schema, [key | keys]) when is_list(schema) do
    case Integer.parse(key) do
      {index, ""} ->
        with {:ok, schema} <- Enum.fetch(schema, index),
             do: do_fetch(schema, keys)

      _ ->
        :error
    end
  end

  defp do_fetch(schema, [key | keys] = pointer) do
    key = decode(key)
    atom_key = Utils.to_existing_atom(key)

    case {Map.get(schema, key), Map.get(schema, atom_key)} do
      {nil, nil} ->
        with {:ok, data} <- Map.fetch(schema, :data),
             do: do_fetch(data, pointer)

      {value, nil} ->
        do_fetch(value, keys)

      {nil, value} ->
        do_fetch(value, keys)
    end
  end

  @doc """
  Fetches a subschema from the `schema` by the given `pointer`.

  If `schema` contains the given pointer with a subschema, then `{:ok, schema}`
  is returned otherwise a `SchemaError` is raised.
  """
  @spec fetch!(Schema.t(), Ref.t() | String.t()) :: Schema.t()
  def fetch!(%Schema{} = schema, pointer) do
    case fetch(schema, pointer) do
      {:ok, schema} -> schema
      :error -> raise SchemaError, {:ref_not_found, pointer}
    end
  end

  # Validates the type/types in the given keywords.
  # The key `:type` can contain a type or a list of types.
  @spec validate_type!(keyword) :: keyword
  defp validate_type!(opts) when is_list(opts) do
    with {:ok, type} <- Keyword.fetch(opts, :type),
         :ok <- validate_type(type) do
      opts
    else
      :error ->
        raise SchemaError, :missing_type

      {:error, types} when is_list(types) ->
        raise SchemaError, {:invalid_types, types}

      {:error, type} ->
        raise SchemaError, {:invalid_type, type}
    end
  end

  # Validates a list of types. Returns a list of invalid types in an error tuple
  # or :ok.
  @spec validate_type([atom]) :: :ok | {:error, [atom]}
  defp validate_type(types) when is_list(types) do
    types
    |> Enum.map(&validate_type/1)
    |> Enum.filter(fn
      :ok -> false
      _ -> true
    end)
    |> case do
      [] -> :ok
      errors -> {:error, Enum.map(errors, fn {:error, type} -> type end)}
    end
  end

  # Validates a type.
  @spec validate_type(atom) :: :ok | {:error, atom}
  defp validate_type(type) when type in @types, do: :ok

  defp validate_type(type), do: {:error, type}

  # This function updates some values in the `keywords`.
  #
  # * const: a `nil` will be updated to `:__nil__` to distinguish an unset value
  #          from `nil`.
  # * pattern: setups a regex for this key.
  # * pattern_properties: setups regexs for this key.
  @spec update(keyword) :: keyword
  defp update(keywords),
    do:
      keywords
      |> Keyword.update(:const, nil, &mark_nil/1)
      |> Keyword.update(:pattern, nil, &pattern/1)
      |> Keyword.update(:pattern_properties, nil, &pattern_properties/1)

  @spec mark_nil(any) :: any | :__nil__
  defp mark_nil(nil), do: :__nil__

  defp mark_nil(value), do: value

  @spec pattern(Regex.t() | String.t() | atom) :: Regex.t()
  defp pattern(string) when is_binary(string), do: Regex.compile!(string)

  defp pattern(regex), do: regex

  @spec pattern_properties(map | nil) :: map | nil
  defp pattern_properties(nil), do: nil

  defp pattern_properties(map),
    do: for(key_value <- map, into: %{}, do: pattern_property(key_value))

  defp pattern_property({pattern, property}) when is_binary(pattern),
    do: {Regex.compile!(pattern), property}

  defp pattern_property({pattern, property}) when is_atom(pattern),
    do: pattern_property({Atom.to_string(pattern), property})

  defp pattern_property(key_value), do: key_value

  @spec delete_nils(map) :: map
  defp delete_nils(schema),
    do: for({k, v} <- schema, not is_nil(v), into: %{}, do: {k, v})

  @spec decode(String.t()) :: String.t()
  defp decode(str) do
    str
    |> String.replace("~0", "~")
    |> String.replace("~1", "/")
    |> URI.decode()
  end
end

defimpl Inspect, for: Xema.Schema do
  def inspect(schema, opts) do
    fields =
      schema
      |> Map.from_struct()
      |> Map.update!(
        :type,
        fn
          :any -> nil
          val -> val
        end
      )
      |> Enum.filter(fn {_, val} -> !is_nil(val) end)
      |> Enum.into(%{})

    infos = for {field, _value} <- fields, do: %{field: field}

    Inspect.Map.inspect(Enum.into(fields, %{}), "Xema.Schema", infos, opts)
  end
end
