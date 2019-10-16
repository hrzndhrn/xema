defmodule Xema.JsonSchema do
  @moduledoc """
  Converts a JSON Schema to Xema source.
  """

  alias Xema.{Schema, SchemaError}

  @type json_schema :: true | false | map
  @type opts :: [draft: 4 | 6 | 7]

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

  @keywords Schema.keywords()
            |> Enum.map(&to_string/1)
            |> ConvCase.to_camel_case()
            |> List.delete("ref")
            |> List.delete("schema")
            |> Enum.concat(["$ref", "$id", "$schema"])

  # TODO: docs
  # TODO: options: draft: 4|6|7, atom: :force | nil
  @spec to_xema(json_schema, opts) :: atom | tuple
  def to_xema(json, opts \\ []) do
    draft = Keyword.get(opts, :draft, 7)
    # TODO: make check
    do_to_xema(json)
  end

  defp do_to_xema(json) when is_map(json) do
    {type, json} = type(json)

    case Enum.empty?(json) do
      true -> type
      false -> {type, schema(json)}
    end
  end

  defp do_to_xema(json) when is_boolean(json), do: json

  defp type(map) do
    {type, map} = Map.pop(map, "type", :any)
    {type_to_atom(type), map}
  end

  defp type_to_atom(list) when is_list(list), do: Enum.map(list, &type_to_atom/1)

  defp type_to_atom("object"), do: :map

  defp type_to_atom("array"), do: :list

  defp type_to_atom("null"), do: nil

  defp type_to_atom(type) when is_binary(type), do: to_existing_atom(type)

  defp type_to_atom(type), do: type

  defp schema(json) do
    json
    |> Enum.map(&rule/1)
    |> Keyword.new()
  end

  # handles all rules with a regular keyword
  defp rule({key, value}) when key in @keywords do
    key
    |> String.trim_leading("$")
    |> ConvCase.to_snake_case()
    |> to_existing_atom()
    |> rule(value)
  end

  # handles all rules without a regular keyword
  defp rule({key, value}) when is_binary(key) and is_map(value) do
    value =
      case schema?(value) do
        true -> do_to_xema(value)
        false -> schema(value)
      end

    {to_existing_atom(key), value}
  end

  defp rule({key, value}), do: {to_existing_atom(key), value}

  defp rule(:format, value) do
    {:format, value |> ConvCase.to_snake_case() |> to_existing_atom()}
  end

  defp rule(:dependencies, value) do
    value =
      Enum.into(value, %{}, fn
        {key, value} when is_map(value) -> {key, do_to_xema(value)}
        {key, value} -> {key, value}
      end)

    {:dependencies, value}
  end

  defp rule(key, value) when key in @schema_map do
    {key, Enum.into(value, %{}, fn {key, value} -> {key, do_to_xema(value)} end)}
  end

  defp rule(key, value) when key in @schemas and is_list(value) do
    {key, Enum.map(value, &do_to_xema/1)}
  end

  defp rule(key, value) when key in @schema do
    {key, do_to_xema(value)}
  end

  defp rule(key, value), do: {key, value}

  defp schema?(value) when is_map(value) do
    value |> Map.keys() |> Enum.any?(fn key -> Enum.member?(@keywords, key) end)
  end

  defp schema?(_), do: false

  defp to_existing_atom(str) do
    String.to_existing_atom(str)
  rescue
    _ ->
      raise SchemaError,
            "All additional schema keys must be existing atoms. Missing atom for #{str}"
  end
end
