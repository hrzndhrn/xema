defmodule Xema.Validator do
  @moduledoc false

  @spec validate(Xema.t(), any) :: :ok | {:error, map}
  def validate(%Xema{} = xema, value) do
    validate(xema.type, value)
  end

  @spec validate(Xema.types(), any) :: :ok | {:error, map}
  def validate(%Xema.Nil{} = type, value) do
    case value == nil do
      true -> :ok
      false -> error(type)
    end
  end

  def validate(%Xema.Number{} = type, value) do
    validate_number(type, value)
  end

  def validate(%Xema.Integer{} = type, value) do
    validate_number(type, value)
  end

  def validate(%Xema.Float{} = type, value) do
    validate_number(type, value)
  end

  def validate(%Xema.Any{} = type, value) do
    enum(type, value)
  end

  def validate(%Xema.Boolean{} = type, value) do
    case is_boolean(value) do
      true -> :ok
      false -> error(type)
    end
  end

  def validate(%Xema.String{} = type, value) do
    with :ok <- type(type, value),
         length <- String.length(value),
         :ok <- min_length(type, length),
         :ok <- max_length(type, length),
         :ok <- pattern(type, value),
         :ok <- enum(type, value),
         do: :ok
  end

  def validate(%Xema.List{} = type, value) do
    with :ok <- type(type, value),
         :ok <- min_items(type, value),
         :ok <- max_items(type, value),
         :ok <- items(type, value),
         :ok <- unique(type, value),
         do: :ok
  end

  def validate(%Xema.Map{} = type, value) do
    with :ok <- type(type, value),
         :ok <- size(type, value),
         :ok <- keys(type, value),
         :ok <- required(type, value),
         :ok <- dependencies(type, value),
         {:ok, value} <- properties(type, value),
         {:ok, value} <- patterns(type, value),
         :ok <- additionals(type, value),
         do: :ok
  end

  @spec validate_number(Xema.types(), any) :: :ok | {:error, map}
  defp validate_number(type, value) do
    with :ok <- type(type, value),
         :ok <- minimum(type, value),
         :ok <- maximum(type, value),
         :ok <- multiple_of(type, value),
         :ok <- enum(type, value) do
      :ok
    end
  end

  @spec type(Xema.types(), any) :: :ok | {:error, map}
  defp type(%Xema.Integer{}, value) when is_integer(value), do: :ok
  defp type(%Xema.Float{}, value) when is_float(value), do: :ok
  defp type(%Xema.Number{}, value) when is_number(value), do: :ok
  defp type(%Xema.String{}, value) when is_binary(value), do: :ok
  defp type(%Xema.List{}, value) when is_list(value), do: :ok
  defp type(%Xema.Map{}, value) when is_map(value), do: :ok
  defp type(type, _value), do: error(type)

  @spec enum(Xema.types(), any) :: :ok | {:error, map}
  defp enum(%{enum: nil}, _element), do: :ok

  defp enum(%{enum: enum}, value) do
    case Enum.member?(enum, value) do
      true -> :ok
      false -> error(:not_in_enum, enum: enum, element: value)
    end
  end

  @spec minimum(Xema.types(), any) :: :ok | {:error, map}
  defp minimum(%{minimum: nil}, _value), do: :ok

  defp minimum(
         %{minimum: minimum, exclusive_minimum: exclusive_minimum},
         value
       ),
       do: minimum(minimum, exclusive_minimum, value)

  @spec minimum(number, boolean, number) :: :ok | {:error, map}
  defp minimum(minimum, _exclusive, value) when value > minimum, do: :ok
  defp minimum(minimum, nil, value) when value == minimum, do: :ok
  defp minimum(minimum, false, value) when value == minimum, do: :ok

  defp minimum(minimum, _exclusive, value) do
    if value != minimum do
      error(:too_small, minimum: minimum)
    else
      error(:too_small, minimum: minimum, exclusive_minimum: true)
    end
  end

  @spec maximum(Xema.types(), any) :: :ok | {:error, map}
  defp maximum(%{maximum: nil}, _value), do: :ok

  defp maximum(
         %{maximum: maximum, exclusive_maximum: exclusive_maximum},
         value
       ),
       do: maximum(maximum, exclusive_maximum, value)

  @spec maximum(number, boolean, number) :: :ok | {:error, map}
  defp maximum(maximum, _exclusive, value) when value < maximum, do: :ok
  defp maximum(maximum, nil, value) when value == maximum, do: :ok
  defp maximum(maximum, false, value) when value == maximum, do: :ok

  defp maximum(maximum, _exclusive, value) do
    if value != maximum do
      error(:too_big, maximum: maximum)
    else
      error(:too_big, maximum: maximum, exclusive_maximum: true)
    end
  end

  @spec multiple_of(Xema.types(), number) :: :ok | {:error, map}
  defp multiple_of(%{multiple_of: nil} = _keywords, _value), do: :ok

  defp multiple_of(%{multiple_of: multiple_of}, value) do
    x = value / multiple_of

    if x - Float.floor(x) == 0,
      do: :ok,
      else: error(:not_multiple, multiple_of: multiple_of)
  end

  defp min_length(%{min_length: nil}, _), do: :ok
  defp min_length(%{min_length: min}, len) when len >= min, do: :ok

  defp min_length(%{min_length: min}, _length) do
    error(:too_short, min_length: min)
  end

  defp max_length(%{max_length: nil}, _length), do: :ok
  defp max_length(%{max_length: max}, len) when len <= max, do: :ok

  defp max_length(%{max_length: max}, _length) do
    error(:too_long, max_length: max)
  end

  defp pattern(%{pattern: nil}, _string), do: :ok

  defp pattern(%{pattern: pattern}, string) do
    case Regex.match?(pattern, string) do
      true -> :ok
      false -> error(:no_match, pattern: pattern)
    end
  end

  defp min_items(%Xema.List{min_items: nil}, _list), do: :ok

  defp min_items(%Xema.List{min_items: min}, list) when length(list) >= min do
    :ok
  end

  defp min_items(%Xema.List{min_items: min}, _list) do
    error(:too_less_items, min_items: min)
  end

  defp max_items(%Xema.List{max_items: nil}, _list), do: :ok

  defp max_items(%Xema.List{max_items: max}, list) when length(list) <= max do
    :ok
  end

  defp max_items(%Xema.List{max_items: max}, _list) do
    error(:too_many_items, max_items: max)
  end

  defp unique(%Xema.List{unique_items: nil}, _list), do: :ok

  defp unique(%Xema.List{unique_items: true}, list) do
    case is_unique?(list) do
      true -> :ok
      false -> error(:not_unique)
    end
  end

  defp is_unique?(list, set \\ %{})
  defp is_unique?([], _), do: true

  defp is_unique?([h | t], set) do
    case set do
      %{^h => true} -> false
      _ -> is_unique?(t, Map.put(set, h, true))
    end
  end

  defp items(%Xema.List{items: nil}, _list), do: :ok

  defp items(
         %Xema.List{items: items, additional_items: additional_items},
         list
       )
       when is_list(items),
       do: items_tuple(items, additional_items, list, 0)

  defp items(%Xema.List{items: items}, list), do: items_list(items, list, 0)

  defp items_list(_schema, [], _at), do: :ok

  defp items_list(schema, [item | list], at) do
    case Xema.validate(schema, item) do
      :ok -> items_list(schema, list, at + 1)
      {:error, reason} -> error(:invalid_item, at: at, error: reason)
    end
  end

  defp items_tuple(_schemas, _additonal_items, [], _at), do: :ok

  defp items_tuple([], false, _list, at), do: error(:additional_item, at: at)
  defp items_tuple([], true, _list, _at), do: :ok
  defp items_tuple([], nil, _list, _at), do: :ok

  defp items_tuple([], schema, [item | list], at) do
    case Xema.validate(schema, item) do
      :ok -> items_tuple([], schema, list, at + 1)
      {:error, reason} -> error(:invalid_item, at: at, error: reason)
    end
  end

  defp items_tuple([schema | schemas], additional_items, [item | list], at) do
    case Xema.validate(schema, item) do
      :ok -> items_tuple(schemas, additional_items, list, at + 1)
      {:error, reason} -> error(:invalid_item, at: at, error: reason)
    end
  end

  defp keys(%Xema.Map{keys: nil}, _value), do: :ok

  defp keys(%Xema.Map{keys: :atoms}, map) do
    case map |> Map.keys() |> Enum.all?(&is_atom/1) do
      true -> :ok
      false -> error(:invalid_keys, keys: :atoms)
    end
  end

  defp keys(%Xema.Map{keys: :strings}, map) do
    case map |> Map.keys() |> Enum.all?(&is_binary/1) do
      true -> :ok
      false -> error(:invalid_keys, keys: :strings)
    end
  end

  defp properties(%Xema.Map{properties: nil}, map), do: {:ok, map}

  defp properties(%Xema.Map{properties: props}, map) do
    do_properties(Map.to_list(props), map)
  end

  defp do_properties([], map), do: {:ok, map}

  defp do_properties([{prop, schema} | props], map) do
    with {:ok, value} <- get_value(map, prop),
         :ok <- do_property(schema, value) do
      do_properties(props, Map.delete(map, prop))
    else
      {:error, reason} ->
        {:error, Map.merge(reason, %{property: get_key(map, prop)})}
    end
  end

  defp do_property(_schema, nil), do: :ok

  defp do_property(schema, value) do
    case Xema.validate(schema, value) do
      :ok -> :ok
      {:error, reason} -> error(:invalid_property, error: reason)
    end
  end

  defp get_value(map, key) when is_atom(key) do
    do_get_value(map, to_string(key), key)
  end

  defp get_value(map, key) do
    do_get_value(map, key, String.to_atom(key))
  end

  defp do_get_value(map, key_string, key_atom) do
    case {Map.get(map, key_string), Map.get(map, key_atom)} do
      {nil, nil} ->
        {:ok, nil}

      {nil, value} ->
        {:ok, value}

      {value, nil} ->
        {:ok, value}

      _ ->
        error(:mixed_map)
    end
  end

  defp get_key(map, key) when is_atom(key) do
    if Map.has_key?(map, key), do: key, else: to_string(key)
  end

  defp get_key(map, key) do
    if Map.has_key?(map, key), do: key, else: String.to_existing_atom(key)
  end

  defp required(%Xema.Map{required: nil}, _map), do: :ok

  defp required(%Xema.Map{required: required}, map) do
    props = map |> Map.keys() |> MapSet.new()

    case MapSet.subset?(required, props) do
      true ->
        :ok

      false ->
        error(
          :missing_properties,
          missing: required |> MapSet.difference(props) |> MapSet.to_list(),
          required: MapSet.to_list(required)
        )
    end
  end

  defp size(%Xema.Map{min_properties: nil, max_properties: nil}, _map), do: :ok

  defp size(%Xema.Map{min_properties: min, max_properties: max}, map) do
    do_size(length(Map.keys(map)), min, max)
  end

  defp do_size(len, min, _max) when not is_nil(min) and len < min do
    error(:too_less_properties, min_properties: min)
  end

  defp do_size(len, _min, max) when not is_nil(max) and len > max do
    error(:too_many_properties, max_properties: max)
  end

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

  defp key_match?(regex, atom) when is_atom(atom) do
    key_match?(regex, to_string(atom))
  end

  defp key_match?(regex, string), do: Regex.match?(regex, string)

  defp additionals(%Xema.Map{additional_properties: false}, map) do
    case Map.equal?(map, %{}) do
      true ->
        :ok

      false ->
        error(
          :no_additional_properties_allowed,
          additional_properties: Map.keys(map)
        )
    end
  end

  defp additionals(_schema, _map), do: :ok

  defp dependencies(%Xema.Map{dependencies: nil}, _map), do: :ok

  defp dependencies(%Xema.Map{dependencies: dependencies}, map) do
    dependencies
    |> Map.to_list()
    |> Enum.filter(fn {key, _} -> Map.has_key?(map, key) end)
    |> do_dependencies(map)
  end

  defp do_dependencies([], _map), do: :ok

  defp do_dependencies([{key, list} | tail], map) when is_list(list) do
    with :ok <- do_dependencies_list(key, list, map) do
      do_dependencies(tail, map)
    end
  end

  defp do_dependencies([{key, schema} | tail], map) do
    with :ok <- Xema.validate(schema, map) do
      do_dependencies(tail, map)
    else
      {:error, error} ->
        error(:invalid_dependency, for: key, error: error)
    end
  end

  defp do_dependencies_list(_key, [], _map), do: :ok

  defp do_dependencies_list(key, [dependency | dependencies], map) do
    case Map.has_key?(map, dependency) do
      true ->
        do_dependencies_list(key, dependencies, map)

      false ->
        error(:missing_dependency, for: key, dependency: dependency)
    end
  end

  defp error(atom) when is_atom(atom), do: error(atom, [])
  defp error(type), do: error(:wrong_type, type: type.as)

  defp error(reason, info) when is_atom(reason) do
    info =
      info
      |> Enum.into(%{})
      |> Map.merge(%{reason: reason})

    {:error, info}
  end
end
