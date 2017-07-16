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
         {:ok, map} <- patterns(keywords, map),
         :ok <- additionals(keywords, map),
      do: :ok
  end

  defp type(_keywords, map) when is_map(map), do: :ok
  defp type(keywords, _map) do
    {:error, %{
      reason: :wrong_type,
      type: keywords.as
    }}
  end

  defp properties(%Xema.Map{properties: nil}, map), do: {:ok, map}
  defp properties(%Xema.Map{properties: props}, map) do
    do_properties(Map.to_list(props), map)
  end

  defp do_properties([], map), do: {:ok, map}
  defp do_properties([{prop, schema}|props], map) do
    case do_property(schema, prop, get_value(map, prop)) do
      :ok -> do_properties(props, Map.delete(map, prop))
      error -> error
    end
  end

  defp do_property(_schema, _prop, nil), do: :ok
  defp do_property(schema, prop, value) do
    case Xema.validate(schema, value) do
      :ok -> :ok
      {:error, reason} ->
        error(:invalid_property, property: prop, error: reason)
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
    props = map |> Map.keys |> MapSet.new

    if MapSet.subset?(required, props) do 
      :ok 
    else 
      error(
        :missing_properties, 
        missing: required |> MapSet.difference(props) |> MapSet.to_list,
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

  defp patterns(%Xema.Map{pattern_properties: nil}, map), do: {:ok, map}
  defp patterns(%Xema.Map{pattern_properties: patterns}, map) do
    props = 
      for {pattern, schema} <- Map.to_list(patterns),
          key <- Map.keys(map),
          key_match?(pattern, key),
          do: {key, schema}


    do_properties(props, map)
  end

  defp key_match?(regex, atom) when is_atom(atom), 
    do: key_match?(regex, to_string(atom)) 
  defp key_match?(regex, string), do: Regex.match?(regex, string)

  defp additionals(%Xema.Map{additional_properties: false}, map) do
    if Map.equal?(map, %{}) do
      :ok
    else
      error(:no_additional_properties_allowed, 
            additional_properties: Map.keys(map))
    end
  end
  defp additionals(_schema, _map), do: :ok
end
