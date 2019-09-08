defmodule Xema.JsonSchema do
  @moduledoc """
  Converts a JSON Schema to Xema source.
  """

  alias Xema.Schema

  @type json_schema :: true | false | map

  @spec to_xema(json_schema :: json_schema) :: atom | tuple
  def to_xema(json) when is_map(json) do
    {type, json} = type(json)

    case Enum.empty?(json) do
      true -> type
      false -> {type, schema(json)}
    end
  end

  defp type(map) do
    {type, map} = Map.pop(map, "type", :any)
    {type_to_atom(type), map}
  end

  defp type_to_atom("object"), do: :map

  defp type_to_atom(type), do: String.to_existing_atom(type)

  defp schema(json), do: json |> Enum.map(&rule/1) |> Keyword.new()

  defp rule({key, value}) when is_binary(key) do
    key
    |> ConvCase.to_snake_case()
    |> String.to_existing_atom()
    |> rule(value)
  end

  defp rule(:properties, value) do
    value = Enum.into(value, %{}, fn {key, property} -> {key, to_xema(property)} end)
    {:properties, value}
  end

  defp rule(key, value), do: {key, value}
end
