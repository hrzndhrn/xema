defmodule Xema.Schema do
  @moduledoc """
  This module contains the struct for the keywords of a schema.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :any
      %Xema{type: %Xema.Schema{type: :any, as: :any}}
      iex> schema.type == %Xema.Schema{type: :any, as: :any}
      true
  """

  @typedoc """
  The struct contains the keywords for a schema.

  * `additional_items` disallow additional items, if set to false. The keyword can also contain a schema to specify the type of additional items.
  * `additional_properties` disallow additional properties, if set to true
  * `as` is used in an error report.
  * `as` is used in an error report. Default of `as` is `:list`
  * `dependencies` allows the schema of the map to change based on the presence of certain special properties
  * `enum` specifies an enumeration
  * `exclusive_maximum` is a boolean. When true, it indicates that the range excludes the maximum value.
  * `exclusive_minimum` is a boolean. When true, it indicates that the range excludes the minimum value.
  * `items` specifies the type(s) of the items
  * `keys` could be `:atoms` or `:strings`
  * `max_items` the maximum length of list
  * `max_length` the maximum length of string
  * `max_properties` the maximum count of properties for the map
  * `maximum` the maximum value
  * `min_items` the minimal length of list
  * `min_length` the minimal length of string
  * `min_properties` the minimal count of properties for the map
  * `minimum` the minimum value
  * `multiple_of` is a number greater 0. The value has to be a multiple of this number.
  * `one_of` the given data must be valid against exactly one of the given subschemas.
  * `pattern_properties` specifies schemas for properties by patterns
  * `pattern` restrict a string to a particular regular expression.
  * `properties` specifies schemas for properties
  * `required` contains a set of required properties
  * `type` specifies the data type for a schema.
  * `unique_items` disallow duplicate items, if set to true
  """
  @type t :: %Xema.Schema{
          additional_items: Xema.t() | Xema.types() | boolean | nil,
          additional_properties: map | boolean | nil,
          as: atom,
          dependencies: list | map | nil,
          enum: list | nil,
          exclusive_maximum: boolean | number | nil,
          exclusive_minimum: boolean | number | nil,
          items: list | Xema.t() | Xema.types() | nil,
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
    :enum,
    :exclusive_maximum,
    :exclusive_minimum,
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
    :type,
    :unique_items
  ]

  @spec new(keyword) :: Xema.Any.t()
  def new(opts \\ []), do: struct(Xema.Schema, update(opts))

  @spec update(keyword) :: keyword
  def update(opts) do
    opts
    |> Keyword.put_new(:as, opts[:type])
    |> Keyword.update(:additional_items, nil, &bool_or_schema/1)
    |> Keyword.update(:additional_properties, nil, &bool_or_schema/1)
    |> Keyword.update(:all_of, nil, &schemas/1)
    |> Keyword.update(:any_of, nil, &schemas/1)
    |> Keyword.update(:dependencies, nil, &dependencies/1)
    |> Keyword.update(:items, nil, &items/1)
    |> Keyword.update(:not, nil, fn schema -> Xema.type(schema) end)
    |> Keyword.update(:one_of, nil, &schemas/1)
    |> Keyword.update(:pattern_properties, nil, &properties/1)
    |> Keyword.update(:properties, nil, &properties/1)
    |> Keyword.update(:required, nil, &MapSet.new(&1))
  end

  @spec schemas(list) :: list
  defp schemas(list), do: Enum.map(list, fn schema -> Xema.type(schema) end)

  @spec properties(map) :: map
  defp properties(map), do: Enum.into(map, %{}, fn {key, prop} -> {key, Xema.type(prop)} end)

  @spec dependencies(map) :: map
  defp dependencies(map),
    do:
      Enum.into(map, %{}, fn
        {key, dep} when is_list(dep) -> {key, dep}
        {key, dep} -> {key, Xema.type(dep)}
      end)

  @spec bool_or_schema(boolean | atom) :: boolean | Xema.Schema.t()
  defp bool_or_schema(bool) when is_boolean(bool), do: bool

  defp bool_or_schema(schema), do: Xema.type(schema)

  defp items(schema) when is_atom(schema), do: Xema.type(schema)

  defp items(schema) when is_tuple(schema), do: Xema.type(schema)

  defp items(schemas) when is_list(schemas), do: schemas(schemas)

  defp items(items), do: items
end
