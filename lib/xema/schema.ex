defmodule Xema.Schema do
  @moduledoc """
  This module contains the struct for the keywords of a schema.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> schema = Xema.new :any
      %Xema{content: %Xema.Schema{type: :any, as: :any}}
      iex> schema.content == %Xema.Schema{type: :any, as: :any}
      true
  """

  alias Xema.Schema

  @typedoc """
  The struct contains the keywords for a schema.

  * `additional_items` disallow additional items, if set to false. The keyword
    can also contain a schema to specify the type of additional items.
  * `additional_properties` disallow additional properties, if set to true.
  * `as` is used in an error report.
  * `as` is used in an error report. Default of `as` is `:list`.
  * `dependencies` allows the schema of the map to change based on the presence
    of certain special properties
  * `description` of the schema.
  * `enum` specifies an enumeration
  * `exclusive_maximum` is a boolean. When true, it indicates that the range
    excludes the maximum value.
  * `exclusive_minimum` is a boolean. When true, it indicates that the range
    excludes the minimum value.
  * `id` a unique identifier.
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
  * `multiple_of` is a number greater 0. The value has to be a multiple of this
    number.
  * `one_of` the given data must be valid against exactly one of the given
    subschemas.
  * `pattern_properties` specifies schemas for properties by patterns
  * `pattern` restrict a string to a particular regular expression.
  * `properties` specifies schemas for properties.
  * `required` contains a set of required properties.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `type` specifies the data type for a schema.
  * `unique_items` disallow duplicate items, if set to true.
  """
  @type t :: %Xema.Schema{
          additional_items: Xema.t() | Xema.Schema.t() | boolean | nil,
          additional_properties: map | boolean | nil,
          as: atom,
          dependencies: list | map | nil,
          description: String.t() | nil,
          enum: list | nil,
          exclusive_maximum: boolean | number | nil,
          exclusive_minimum: boolean | number | nil,
          id: String.t() | nil,
          items: list | Xema.t() | Xema.Schema.t() | nil,
          keys: atom | nil,
          max_items: pos_integer | nil,
          max_length: pos_integer | nil,
          max_properties: pos_integer | nil,
          maximum: number | nil,
          min_items: pos_integer | nil,
          min_length: pos_integer | nil,
          min_properties: pos_integer | nil,
          minimum: number | nil,
          multiple_of: number | nil,
          pattern: Regex.t() | nil,
          pattern_properties: map | nil,
          properties: map | nil,
          required: MapSet.t() | nil,
          schema: String.t() | nil,
          title: String.t() | nil,
          type: atom,
          unique_items: boolean | nil
        }

  defstruct [
    :additional_items,
    :additional_properties,
    :all_of,
    :any_of,
    :as,
    :dependencies,
    :description,
    :enum,
    :exclusive_maximum,
    :exclusive_minimum,
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
    :required,
    :schema,
    :title,
    :type,
    :unique_items
  ]

  @spec new(keyword) :: Xema.Schema.t()
  def new(opts \\ []), do: struct(Xema.Schema, update(opts))

  @spec update(keyword) :: keyword
  defp update(opts) do
    opts
    |> Keyword.put_new(:as, opts[:type])
    |> Keyword.update(:additional_items, nil, &bool_or_schema/1)
    |> Keyword.update(:additional_properties, nil, &bool_or_schema/1)
    |> Keyword.update(:all_of, nil, &schemas/1)
    |> Keyword.update(:any_of, nil, &schemas/1)
    |> Keyword.update(:dependencies, nil, &dependencies/1)
    |> Keyword.update(:items, nil, &items/1)
    |> Keyword.update(:not, nil, fn schema -> Xema.schema(schema) end)
    |> Keyword.update(:one_of, nil, &schemas/1)
    |> Keyword.update(:pattern_properties, nil, &properties/1)
    |> Keyword.update(:properties, nil, &properties/1)
    |> Keyword.update(:required, nil, &MapSet.new(&1))
  end

  @spec schemas(list) :: list
  defp schemas(list), do: Enum.map(list, fn schema -> Xema.schema(schema) end)

  @spec properties(map) :: map
  defp properties(map),
    do: Enum.into(map, %{}, fn {key, prop} -> {key, Xema.schema(prop)} end)

  @spec dependencies(map) :: map
  defp dependencies(map),
    do:
      Enum.into(map, %{}, fn
        {key, dep} when is_list(dep) -> {key, dep}
        {key, dep} -> {key, Xema.schema(dep)}
      end)

  @spec bool_or_schema(boolean | atom) :: boolean | Xema.Schema.t()
  defp bool_or_schema(bool) when is_boolean(bool), do: bool

  defp bool_or_schema(schema), do: Xema.schema(schema)

  defp items(schema) when is_atom(schema), do: Xema.schema(schema)

  defp items(schema) when is_tuple(schema), do: Xema.schema(schema)

  defp items(schemas) when is_list(schemas), do: schemas(schemas)

  defp items(items), do: items

  @spec to_string(any, keyword) :: String.t()
  def to_string(schema, opts \\ [])

  def to_string(%Xema.Schema{} = schema, opts) do
    format = Keyword.get(opts, :format, :data)
    keywords = Keyword.get(opts, :keywords, [])
    root = Keyword.get(opts, :root, true)
    tuple = to_tuple(schema, keywords)

    do_to_string(format, tuple, root)
  end

  def to_string(value, _opts), do: inspect(value)

  @spec do_to_string(atom, tuple, atom) :: String.t()
  defp do_to_string(:data, tuple, root) do
    case tuple do
      {type, []} when root -> inspect({type})
      {type, []} -> inspect(type)
      {type, keywords} -> "{:#{type}, #{keywords_to_string(keywords)}}"
    end
  end

  defp do_to_string(:call, tuple, _root) do
    case tuple do
      {type, []} -> inspect(type)
      {type, keywords} -> ":#{type}, #{keywords_to_string(keywords)}"
    end
  end

  @spec keywords_to_string(keyword) :: String.t()
  defp keywords_to_string(keywords) do
    keywords
    |> Enum.sort()
    |> Enum.map(fn {key, value} -> "#{key}: #{value_to_string(value)}" end)
    |> Enum.join(", ")
  end

  @spec value_to_string(any) :: String.t()
  defp value_to_string(list) when is_list(list) do
    list
    |> Enum.map(fn value -> Schema.to_string(value, root: false) end)
    |> Enum.join(", ")
    |> wrap("[", "]")
  end

  defp value_to_string(map) when is_map(map),
    do:
      map
      |> Enum.map(&key_value_to_string/1)
      |> Enum.join(", ")
      |> wrap("%{", "}")

  defp value_to_string(value), do: inspect(value)

  @spec key_value_to_string({atom | String.t(), any}) :: String.t()
  defp key_value_to_string({key, value}) when is_atom(key),
    do: "#{key}: #{Schema.to_string(value, root: false)}"

  defp key_value_to_string({key, value}) when is_binary(key),
    do: ~s("#{key}" => #{Schema.to_string(value, root: false)})

  @spec wrap(String.t(), String.t(), String.t()) :: String.t()
  defp wrap(str, trailing, pending), do: "#{trailing}#{str}#{pending}"

  @spec to_tuple(Xema.Schema.t(), keyword) :: tuple
  defp to_tuple(%Xema.Schema{} = schema, keywords) do
    schema
    |> Map.from_struct()
    |> delete_as()
    |> delete_nils()
    |> extract_type()
    |> merge(keywords)
  end

  @spec delete_as(map) :: map
  defp delete_as(%{type: type, as: type} = schema), do: Map.delete(schema, :as)

  defp delete_as(schema), do: schema

  @spec delete_nils(map) :: map
  defp delete_nils(schema),
    do: for({k, v} <- schema, not is_nil(v), into: %{}, do: {k, v})

  @spec extract_type(map) :: {atom, keyword}
  defp extract_type(%{type: type} = schema),
    do: {type, schema |> Map.delete(:type) |> Map.to_list()}

  @spec merge({atom, keyword}, keyword) :: {atom, keyword}
  defp merge({type, keywords}, add), do: {type, Keyword.merge(keywords, add)}
end
