defmodule Xema.Map do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct as: :map,
            string_keys: false,
            properties: nil

  @spec keywords(list) :: %Xema.Map{}
  def keywords(keywords), do: struct(%Xema.Map{}, keywords)

  @spec is_valid?(%Xema.Map{}, any) :: boolean
  def is_valid?(keywords, map), do: validate(keywords, map) == :ok

  @spec validate(%Xema.Map{}, any) :: :ok | {:error, atom, any}
  def validate(keywords, map) do
    with :ok <- type(keywords, map),
         :ok <- properties(keywords, map),
      do: :ok
  end

  defp type(_keywords, map) when is_map(map), do: :ok
  defp type(keywords, _map), do: {:error, :wrong_type, %{type: keywords.as}}

  defp properties(%Xema.Map{properties: nil}, _map), do: :ok
  defp properties(%Xema.Map{properties: properties}, map) do
    validate_properties(Map.to_list(properties), map)
  end

  defp validate_properties([], _map), do: :ok
  defp validate_properties([{property, schema}|properties], map) do
    case validate_property(schema, property, get_value(map, property)) do
      :ok -> validate_properties(properties, map)
      error -> error
    end
  end

  defp validate_property(_schema, _propertey, nil), do: :ok
  defp validate_property(schema, property, value) do
    case Xema.validate(schema, value) do
      :ok -> :ok
      {:error, _, _} = error ->
        {:error, :invalid_property, %{property: property, error: error}}
    end
  end

  defp get_value(map, key) do
    case {Map.get(map, key), Map.get(map, to_string key)} do
      {nil, nil} -> nil
      {nil, value} -> value
      {value, nil} -> value
      _ -> {:erro, :mixed_map}
    end
  end
end
