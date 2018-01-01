defmodule Xema.Schema do
  @moduledoc """
  This module contains the struct for the keywords of type `any`.

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
  The struct contains the keywords for the type `any`.

  * `as` is used in an error report. Default of `as` is `:any`
  * `enum` specifies an enumeration
  """
  @type t :: %Xema.Any{enum: list | nil, as: atom}

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
    :minimum,
    :multiple_of,
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
