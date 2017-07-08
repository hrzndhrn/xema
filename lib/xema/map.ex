defmodule Xema.Map do
  @moduledoc """
  TODO
  """

  import Xema.Error

  @behaviour Xema

  defstruct [
    :additonal_properties,
    :max_properties,
    :min_properties,
    :properties,
    as: :map
  ]

  @spec keywords(list) :: %Xema.Map{}
  def keywords(keywords), do: struct(%Xema.Map{}, keywords)

  @spec is_valid?(%Xema.Map{}, any) :: boolean
  def is_valid?(keywords, map), do: validate(keywords, map) == :ok

  @spec validate(%Xema.Map{}, any) :: :ok | {:error, map}
  def validate(keywords, map) do
    with :ok <- type(keywords, map),
         :ok <- properties(keywords, map),
         :ok <- size(keywords, map),
         :ok <- additonal_properties(keywords, map),
      do: :ok
  end

  defp type(_keywords, map) when is_map(map), do: :ok
  defp type(keywords, _map) do
    {:error, %{
      reason: :wrong_type,
      type: keywords.as
    }}
  end

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

  defp validate_property(_schema, _property, nil), do: :ok
  defp validate_property(schema, property, value) do
    case Xema.validate(schema, value) do
      :ok -> :ok
      {:error, reason} ->
        error(:invalid_property, property: property, error: reason)
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

  defp size(%Xema.Map{min_properties: nil, max_properties: nil}, _map), do: :ok
  defp size(%Xema.Map{min_properties: min, max_properties: max}, map),
    do: do_size(length(Map.keys(map)), min, max)

  defp do_size(len, min, _max)
    when not is_nil(min) and len < min,
    do: error(:too_less_properties, min_properties: min)
  defp do_size(len, _min, max)
    when not is_nil(max) and len > max,
    do: error(:too_many_properties, max_properties: max)
  defp do_size(_len, _min, _max), do: :ok

  defp additonal_properties(%Xema.Map{additonal_properties: nil}, _map), do: :ok
  defp additonal_properties(
    %Xema.Map{additonal_properties: false, properties: properties},
    map
  ) do
    additional_properties =
      map
      |> Map.keys
      |> MapSet.new
      |> MapSet.difference(properties |> Map.keys |> MapSet.new)
      |> MapSet.to_list

    if Enum.empty?(additional_properties) do
      :ok
    else
      error(
        :no_additional_properties_allowed,
        additonal_properties: additional_properties)
    end
  end
end
