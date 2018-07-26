defmodule Xema.Schema do
  @moduledoc """
  This module contains the struct for the keywords of a schema.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> schema = Xema.new :any
      %Xema{content: %Xema.Schema{type: :any}}
      iex> schema.content == %Xema.Schema{type: :any}
      true
  """

  alias Xema.Ref
  alias Xema.Schema

  @typedoc """
  The struct contains the keywords for a schema.

  * `additional_items` disallow additional items, if set to false. The keyword
    can also contain a schema to specify the type of additional items.
  * `additional_properties` disallow additional properties, if set to true.
  * `const` specifies a constant.
  * `definitions` contains schemas for reuse.
  * `dependencies` allows the schema of the map to change based on the presence
    of certain special properties
  * `description` of the schema.
  * `enum` specifies an enumeration
  * `exclusive_maximum` is a boolean. When true, it indicates that the range
    excludes the maximum value.
  * `exclusive_minimum` is a boolean. When true, it indicates that the range
    excludes the minimum value.
  * `format` semantic validation.
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
  * `ref` a reference to a schema.
  * `required` contains a set of required properties.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `type` specifies the data type for a schema.
  * `unique_items` disallow duplicate items, if set to true.
  """
  @type t :: %Xema.Schema{
          additional_items: Xema.t() | Xema.Schema.t() | boolean | nil,
          additional_properties: map | boolean | nil,
          const: any,
          definitions: map,
          dependencies: list | map | nil,
          description: String.t() | nil,
          enum: list | nil,
          exclusive_maximum: boolean | number | nil,
          exclusive_minimum: boolean | number | nil,
          format: atom | nil,
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
          ref: Ref.t() | nil,
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
    :const,
    :definitions,
    :dependencies,
    :description,
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
    :schema,
    :title,
    :type,
    :unique_items
  ]

  @spec new(keyword) :: Schema.t()
  def new(opts \\ []), do: struct(Xema.Schema, update(opts))

  @spec to_map(Schema.t()) :: map
  def to_map(schema),
    do:
      schema
      |> Map.from_struct()
      |> delete_nils()

  @spec update(keyword) :: keyword
  defp update(opts),
    do:
      opts
      |> Keyword.update(:pattern, nil, &pattern/1)
      |> Keyword.update(:pattern_properties, nil, &pattern_properties/1)
      |> Keyword.update(:ref, nil, &ref/1)

  @spec pattern(Regex.t() | String.t() | atom) :: Regex.t()
  defp pattern(string) when is_binary(string), do: Regex.compile!(string)

  defp pattern(atom) when is_atom(atom), do: pattern(Atom.to_string(atom))

  defp pattern(regex), do: regex

  @spec pattern_properties(map) :: map
  defp pattern_properties(nil), do: nil

  defp pattern_properties(map) do
    for key_value <- map, into: %{}, do: pattern_property(key_value)
  end

  defp pattern_property({pattern, property}) when is_binary(pattern) do
    {Regex.compile!(pattern), property}
  end

  defp pattern_property({pattern, property}) when is_atom(pattern) do
    pattern_property({Atom.to_string(pattern), property})
  end

  defp pattern_property(key_value), do: key_value

  @spec delete_nils(map) :: map
  defp delete_nils(schema),
    do: for({k, v} <- schema, not is_nil(v), into: %{}, do: {k, v})

  @spec ref(String.t()) :: Ref.t()
  defp ref(pointer), do: Ref.new(pointer)
end
