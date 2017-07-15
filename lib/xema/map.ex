defmodule Xema.Map do
  @moduledoc """
  TODO
  """

  import Xema.Error

  @behaviour Xema

  defstruct [
    :additional_properties,
    :max_properties,
    :min_properties,
    :properties,
    :required,
    :pattern_properties,
    as: :map
  ]

  @spec keywords(keyword) :: %Xema.Map{}
  def keywords(keywords), do: struct(%Xema.Map{}, setup(keywords))

  defp setup(keywords) do
    keywords
    |> Keyword.update(:required, nil, fn x -> MapSet.new(x) end)
  end

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(xema, map), do: validate(xema, map) == :ok

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
  def validate(%Xema{keywords: keywords}, map) do
    with :ok <- type(keywords, map),
         :ok <- size(keywords, map),
         :ok <- required(keywords, map),
         {:ok, map} <- properties(keywords, map),
         :ok <- additional_properties(keywords, map),
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

  defp validate_properties([], map), do: {:ok, map}
  defp validate_properties([{property, schema}|properties], map) do
    case validate_property(schema, property, get_value(map, property)) do
      :ok -> validate_properties(properties, Map.delete(map, property))
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

  defp get_value(map, key) when is_atom(key) do
    case {Map.get(map, key), Map.get(map, to_string key)} do
      {nil, nil} -> nil
      {nil, value} -> value
      {value, nil} -> value
      _ -> {:erro, :mixed_map}
    end
  end
  defp get_value(map, key) do
    case {Map.get(map, key), Map.get(map, String.to_atom key)} do
      {nil, nil} -> nil
      {nil, value} -> value
      {value, nil} -> value
      _ -> {:erro, :mixed_map}
    end
  end
  
  defp required(%Xema.Map{required: nil}, _map), do: :ok
  defp required(%Xema.Map{required: required}, map) do
    properties = map |> Map.keys |> MapSet.new

    if MapSet.subset?(required, properties) do 
      :ok 
    else 
      error(
        :missing_properties, 
        missing: required |> MapSet.difference(properties) |> MapSet.to_list,
        required: MapSet.to_list(required)
      )
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

  defp additional_properties(schema, map) do
    case schema.additional_properties do
      nil -> :ok

      false -> 
        if Map.equal?(map, %{}) do
          :ok
        else
          error(:no_additional_properties_allowed, 
                additional_properties: Map.keys(map))
        end
    end
  end

  defp do_additional_properties(props, nil, map) do
    additional_properties =
      map
      |> Map.keys
      |> MapSet.new
      |> MapSet.difference(props |> Map.keys |> MapSet.new)
      |> MapSet.to_list

    if Enum.empty?(additional_properties) do
      :ok
    else
      error(
        :no_additional_properties_allowed,
        additional_properties: additional_properties)
    end
  end
  defp do_additional_properties(nil, patterns, map) do
    properties =
      map
      |> Map.keys
      |> Enum.map(fn x -> to_string x end)

    patterns = Map.keys(patterns)
      
    do_additional_properties_match(properties, patterns)
  end
  defp do_additional_properties(props, patterns, map) do
    with :ok <- do_additional_properties(props, nil, map),
         :ok <- do_additional_properties(nil, patterns, map),
      do: :ok
  end

  defp do_additional_properties_match([], _patterns), do: :ok
  defp do_additional_properties_match([prop|props], patterns) do 
    if Enum.any?(patterns, fn pattern -> Regex.match?(pattern, prop) end) do
      do_additional_properties_match(props, patterns)
    else
      error(:no_pattern_match, property: prop, patterns: patterns)
    end
  end
end
