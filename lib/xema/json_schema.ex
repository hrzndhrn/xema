defmodule Xema.JsonSchema do
  @moduledoc """
  Converts a JSON Schema to Xema source.
  """

  @type json_schema :: true | false | map
  @schema ~w(
    additional_items
    additional_properties
    property_names
    not
    if
    then
    else
    contains
    items
  )a

  @schemas ~w(
    all_of
    any_of
    one_of
    items
  )a

  @schema_map ~w(
    definitions
    pattern_properties
    properties
  )a

  @spec to_xema(json_schema :: json_schema) :: atom | tuple
  def to_xema(json) when is_map(json) do
    {type, json} = type(json)

    case Enum.empty?(json) do
      true -> type
      false -> {type, schema(json)}
    end
  end

  def to_xema(json) when is_boolean(json), do: json

  defp type(map) do
    {type, map} = Map.pop(map, "type", :any)
    {type_to_atom(type), map}
  end

  defp type_to_atom(list) when is_list(list), do: Enum.map(list, &type_to_atom/1)

  defp type_to_atom("object"), do: :map

  defp type_to_atom("array"), do: :list

  defp type_to_atom("null"), do: nil

  defp type_to_atom(type) when is_binary(type), do: String.to_existing_atom(type)

  defp type_to_atom(type), do: type

  defp schema(json), do: json |> Enum.map(&rule/1) |> Keyword.new()

  defp rule({key, value}) when is_binary(key) do
    key
    |> String.trim_leading("$")
    |> ConvCase.to_snake_case()
    |> String.to_existing_atom()
    |> rule(value)
  end

  defp rule(:format, value) do
    {:format, value |> ConvCase.to_snake_case() |> String.to_existing_atom()}
  end

  defp rule(:dependencies, value) do
    value =
      Enum.into(value, %{}, fn
        {key, value} when is_map(value) -> {key, to_xema(value)}
        {key, value} -> {key, value}
      end)

    {:dependencies, value}
  end

  defp rule(key, value) when key in @schema_map do
    {key, Enum.into(value, %{}, fn {key, value} -> {key, to_xema(value)} end)}
  end

  defp rule(key, value) when key in @schemas and is_list(value) do
    {key, Enum.map(value, &to_xema/1)}
  end

  defp rule(key, value) when key in @schema do
    {key, to_xema(value)}
  end

  defp rule(key, value), do: {key, value}
end
