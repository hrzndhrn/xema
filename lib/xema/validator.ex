defmodule Xema.Validator do
  @moduledoc false

  use Xema.Format

  import Xema.Utils

  alias Xema.Ref
  alias Xema.Schema

  @type result :: :ok | {:error, map}

  @types [:boolean, :atom, :string, :integer, :float, :number, :list, :map, nil]

  @spec validate(Xema.t(), any, keyword) :: result
  def validate(%{content: schema} = xema, value, opts) do
    opts = Keyword.put_new(opts, :root, xema)
    do_validate(schema, value, opts)
  end

  def validate(%Schema{} = schema, value, opts),
    do: do_validate(schema, value, opts)

  @spec do_validate(Xema.t() | Xema.Schema.t(), any, keyword) :: result
  defp do_validate(%{content: schema}, value, opts),
    do: do_validate(schema, value, opts)

  defp do_validate(%Ref{} = ref, value, opts),
    do: Ref.validate(ref, value, opts)

  defp do_validate(%Schema{type: true}, _value, _opts), do: :ok

  defp do_validate(%{type: false}, _value, _opts), do: {:error, %{type: false}}

  defp do_validate(schema, value, opts) do
    opts =
      case schema.id do
        nil -> opts
        id -> update_id(opts, id)
      end

    case schema do
      %{type: list} when is_list(list) ->
        with {:ok, type} <- types(schema, value),
             :ok <- do_validate(%{schema | type: type}, value, opts),
             do: :ok

      %{type: :any, ref: nil} ->
        with type <- get_type(value),
             :ok <- do_validate(:default, schema, value, opts),
             :ok <- do_validate(type, schema, value, opts),
             do: :ok

      %{type: :any, ref: ref} ->
        Ref.validate(ref, value, opts)

      %{type: :string} ->
        with :ok <- type(schema, value),
             :ok <- do_validate(:default, schema, value, opts),
             :ok <- do_validate(:string, schema, value, opts),
             do: :ok

      %{type: :list} ->
        with :ok <- type(schema, value),
             :ok <- do_validate(:list, schema, value, opts),
             do: :ok

      %{type: :map} ->
        with :ok <- type(schema, value),
             :ok <- do_validate(:map, schema, value, opts),
             do: :ok

      %{type: type} when is_atom(type) ->
        do_validate(type, schema, value, opts)
    end
  end

  defp do_validate(:default, schema, value, opts) do
    with :ok <- enum(schema, value),
         :ok <- validate_not(schema, value, opts),
         :ok <- validate_all_of(schema, value, opts),
         :ok <- validate_any_of(schema, value, opts),
         :ok <- validate_one_of(schema, value, opts),
         do: :ok
  end

  defp do_validate(:string, schema, value, _opts) do
    with length <- String.length(value),
         :ok <- min_length(schema, length, value),
         :ok <- max_length(schema, length, value),
         :ok <- pattern(schema, value),
         :ok <- format(schema, value),
         :ok <- enum(schema, value),
         do: :ok
  end

  defp do_validate(nil, _schema, nil, _opts), do: :ok

  defp do_validate(nil, schema, value, _opts),
    do: {:error, %{value: value, type: schema.type}}

  defp do_validate(:list, schema, value, opts) do
    with :ok <- min_items(schema, value),
         :ok <- max_items(schema, value),
         :ok <- items(schema, value, opts),
         :ok <- unique(schema, value),
         do: :ok
  end

  defp do_validate(:map, schema, value, opts) do
    with :ok <- size(schema, value),
         :ok <- keys(schema, value),
         :ok <- required(schema, value),
         :ok <- dependencies(schema, value, opts),
         {:ok, patts_rest} <- patterns(schema, value, opts),
         {:ok, props_rest} <- properties(schema, value, opts),
         value <- intersection(props_rest, patts_rest),
         :ok <- additionals(schema, value, opts),
         do: :ok
  end

  defp do_validate(:boolean, schema, value, _opts) do
    case is_boolean(value) do
      true -> :ok
      false -> {:error, %{value: value, type: schema.type}}
    end
  end

  defp do_validate(:integer, schema, value, opts),
    do: do_validate(:number, schema, value, opts)

  defp do_validate(:float, schema, value, opts),
    do: do_validate(:number, schema, value, opts)

  defp do_validate(:number, schema, value, opts) do
    with :ok <- type(schema, value),
         :ok <- minimum(schema, value),
         :ok <- maximum(schema, value),
         :ok <- exclusive_maximum(schema, value),
         :ok <- exclusive_minimum(schema, value),
         :ok <- multiple_of(schema, value),
         :ok <- do_validate(:default, schema, value, opts),
         do: :ok
  end

  defp do_validate(:atom, _, _, _), do: :ok

  #
  # Schema type handling
  #

  defp get_type(value),
    do: Enum.find(@types, fn type -> is_type?(type, value) end)

  @spec type(Xema.Schema.t() | atom, any) :: result
  defp type(%{type: type} = schema, value) do
    case is_type?(type, value) do
      true -> :ok
      false -> {:error, %{type: schema.type, value: value}}
    end
  end

  @spec is_type?(atom, any) :: boolean
  defp is_type?(:any, _value), do: true
  defp is_type?(:atom, value), do: is_atom(value)
  defp is_type?(:string, value), do: is_binary(value)
  defp is_type?(:number, value), do: is_number(value)
  defp is_type?(:integer, value), do: is_integer(value)
  defp is_type?(:float, value), do: is_float(value)
  defp is_type?(:map, value), do: is_map(value)
  defp is_type?(:list, value), do: is_list(value)
  defp is_type?(:boolean, value), do: is_boolean(value)
  defp is_type?(nil, nil), do: true
  defp is_type?(_, _), do: false

  @spec types(Schema.t(), any) :: {:ok, atom} | {:error, map}
  defp types(%{type: list}, value) do
    case Enum.find(list, :not_found, fn type -> is_type?(type, value) end) do
      :not_found -> {:error, %{type: list, value: value}}
      found -> {:ok, found}
    end
  end

  #
  # Validators
  #

  @spec enum(Xema.Schema.t(), any) :: result
  defp enum(%{enum: nil}, _element), do: :ok

  defp enum(%{enum: enum}, value) do
    case Enum.member?(enum, value) do
      true -> :ok
      false -> {:error, %{enum: enum, value: value}}
    end
  end

  @spec validate_not(Xema.Schema.t(), any, keyword) :: result
  defp validate_not(%{not: nil}, _value, _opts), do: :ok

  defp validate_not(%{not: schema}, value, opts) do
    case do_validate(schema, value, opts) do
      :ok -> {:error, %{not: :ok, value: value}}
      _ -> :ok
    end
  end

  @spec validate_all_of(Xema.Schema.t(), any, keyword) :: result
  defp validate_all_of(%{all_of: nil}, _value, _opts), do: :ok

  defp validate_all_of(%{all_of: schemas}, value, opts) do
    case do_validate_all_of(schemas, value, opts) do
      :ok -> :ok
      {:error, errors} -> {:error, %{all_of: errors, value: value}}
    end
  end

  @spec do_validate_all_of(list, any, keyword, [map]) :: boolean
  defp do_validate_all_of(schemas, value, opts, errors \\ [])

  defp do_validate_all_of([], _value, _opts, []), do: :ok

  defp do_validate_all_of([], _value, _opts, errors),
    do: {:error, Enum.reverse(errors)}

  defp do_validate_all_of([schema | schemas], value, opts, errors) do
    case do_validate(schema, value, opts) do
      :ok ->
        do_validate_all_of(schemas, value, opts, errors)

      {:error, error} ->
        error = Map.delete(error, :value)
        do_validate_all_of(schemas, value, opts, [error | errors])
    end
  end

  @spec validate_any_of(Xema.Schema.t(), any, keyword) :: result
  defp validate_any_of(%{any_of: nil}, _value, _opts), do: :ok

  defp validate_any_of(%{any_of: schemas}, value, opts) do
    case do_validate_any_of(schemas, value, opts) do
      :ok ->
        :ok

      {:error, errors} ->
        {:error, %{any_of: Enum.reverse(errors), value: value}}
    end
  end

  @spec do_validate_any_of(list, any, keyword, [map]) :: boolean
  defp do_validate_any_of(schemas, value, opts, errors \\ [])

  defp do_validate_any_of([], _value, _opts, errors) do
    {:error, errors}
  end

  defp do_validate_any_of([schema | schemas], value, opts, errors) do
    case do_validate(schema, value, opts) do
      :ok ->
        :ok

      {:error, error} ->
        error = Map.delete(error, :value)
        do_validate_any_of(schemas, value, opts, [error | errors])
    end
  end

  @spec validate_one_of(Xema.Schema.t(), any, keyword) :: result
  defp validate_one_of(%{one_of: nil}, _value, _opts), do: :ok

  defp validate_one_of(%{one_of: schemas}, value, opts) do
    errors = do_validate_one_of(schemas, value, opts)

    case length(schemas) - length(errors) do
      1 -> :ok
      _ -> {:error, %{one_of: errors, value: value}}
    end
  end

  @spec do_validate_one_of(list, any, keyword) :: [map]
  defp do_validate_one_of(schemas, value, opts),
    do:
      Enum.reduce(schemas, [], fn schema, acc ->
        case do_validate(schema, value, opts) do
          :ok ->
            acc

          {:error, error} ->
            error = Map.delete(error, :value)
            [error | acc]
        end
      end)

  @spec exclusive_maximum(Xema.Schema.t(), any) :: result
  defp exclusive_maximum(%{exclusive_maximum: nil}, _value), do: :ok

  defp exclusive_maximum(%{exclusive_maximum: max}, _value)
       when is_boolean(max),
       do: :ok

  defp exclusive_maximum(%{exclusive_maximum: max}, value)
       when value < max,
       do: :ok

  defp exclusive_maximum(%{exclusive_maximum: max}, value),
    do: {:error, %{exclusive_maximum: max, value: value}}

  @spec exclusive_minimum(Xema.Schema.t(), any) :: result
  defp exclusive_minimum(%{exclusive_minimum: nil}, _value), do: :ok

  defp exclusive_minimum(%{exclusive_minimum: min}, _value)
       when is_boolean(min),
       do: :ok

  defp exclusive_minimum(%{exclusive_minimum: min}, value)
       when value > min,
       do: :ok

  defp exclusive_minimum(%{exclusive_minimum: min}, value),
    do: {:error, %{value: value, exclusive_minimum: min}}

  @spec minimum(Xema.Schema.t(), any) :: result
  defp minimum(%{minimum: nil}, _value), do: :ok

  defp minimum(
         %{minimum: minimum, exclusive_minimum: exclusive_minimum},
         value
       )
       when is_number(value),
       do: minimum(minimum, exclusive_minimum, value)

  defp minimum(_, _), do: :ok

  @spec minimum(number, boolean, number) :: result
  defp minimum(minimum, _exclusive, value) when value > minimum, do: :ok
  defp minimum(minimum, nil, value) when value == minimum, do: :ok
  defp minimum(minimum, false, value) when value == minimum, do: :ok

  defp minimum(minimum, nil, value),
    do: {:error, %{value: value, minimum: minimum}}

  defp minimum(minimum, exclusive, value),
    do:
      {:error, %{value: value, minimum: minimum, exclusive_minimum: exclusive}}

  @spec maximum(Xema.Schema.t(), any) :: result
  defp maximum(%{maximum: nil}, _value), do: :ok

  defp maximum(
         %{maximum: maximum, exclusive_maximum: exclusive_maximum},
         value
       ),
       do: maximum(maximum, exclusive_maximum, value)

  @spec maximum(number, boolean, number) :: result
  defp maximum(maximum, _exclusive, value) when value < maximum, do: :ok
  defp maximum(maximum, nil, value) when value == maximum, do: :ok
  defp maximum(maximum, false, value) when value == maximum, do: :ok

  defp maximum(maximum, nil, value),
    do: {:error, %{value: value, maximum: maximum}}

  defp maximum(maximum, exclusive, value),
    do:
      {:error, %{value: value, maximum: maximum, exclusive_maximum: exclusive}}

  @spec multiple_of(Xema.Schema.t(), number) :: result
  defp multiple_of(%{multiple_of: nil} = _keywords, _value), do: :ok

  defp multiple_of(%{multiple_of: multiple_of}, value) when is_number(value) do
    x = value / multiple_of

    case x - Float.floor(x) do
      0.0 -> :ok
      _ -> {:error, %{value: value, multiple_of: multiple_of}}
    end
  end

  defp multiple_of(_, _), do: :ok

  @spec min_length(Xema.Schema.t(), integer, String.t()) :: result
  defp min_length(%{min_length: nil}, _, _), do: :ok
  defp min_length(%{min_length: min}, len, _) when len >= min, do: :ok

  defp min_length(%{min_length: min}, _, value),
    do: {:error, %{value: value, min_length: min}}

  @spec max_length(Xema.Schema.t(), integer, String.t()) :: result
  defp max_length(%{max_length: nil}, _, _), do: :ok
  defp max_length(%{max_length: max}, len, _) when len <= max, do: :ok

  defp max_length(%{max_length: max}, _, value),
    do: {:error, %{value: value, max_length: max}}

  @spec pattern(Xema.Schema.t(), String.t()) :: result
  defp pattern(%{pattern: nil}, _string), do: :ok

  defp pattern(%{pattern: pattern}, string) do
    case Regex.match?(pattern, string) do
      true -> :ok
      false -> {:error, %{value: string, pattern: pattern}}
    end
  end

  @spec min_items(Xema.Schema.t(), list) :: result
  defp min_items(%{min_items: nil}, _list), do: :ok

  defp min_items(%{min_items: min}, list) when length(list) >= min do
    :ok
  end

  defp min_items(%{min_items: min}, list),
    do: {:error, %{value: list, min_items: min}}

  @spec max_items(Xema.Schema.t(), list) :: result
  defp max_items(%{max_items: nil}, _list), do: :ok

  defp max_items(%{max_items: max}, list) when length(list) <= max do
    :ok
  end

  defp max_items(%{max_items: max}, list),
    do: {:error, %{value: list, max_items: max}}

  @spec unique(Xema.Schema.t(), list) :: result
  defp unique(%{unique_items: nil}, _list), do: :ok

  defp unique(%{unique_items: true}, list) do
    case is_unique?(list) do
      true -> :ok
      false -> {:error, %{value: list, unique_items: true}}
    end
  end

  @spec is_unique?(list, map) :: boolean
  def is_unique?(list, set \\ %{})
  def is_unique?([], _), do: true

  def is_unique?([h | t], set) do
    case set do
      %{^h => true} -> false
      _ -> is_unique?(t, Map.put(set, h, true))
    end
  end

  @spec items(Xema.Schema.t(), list, keyword) :: result
  defp items(%{items: nil}, _list, _opts), do: :ok

  defp items(%{items: items, additional_items: additional_items}, list, opts)
       when is_list(items),
       do:
         items_tuple(
           items,
           update_nil(additional_items, true),
           list,
           0,
           [],
           opts
         )

  defp items(%{items: items}, list, opts),
    do: items_list(items, list, 0, [], opts)

  @spec items_list(Xema.Schema.t(), list, integer, list, keyword) :: result
  defp items_list(_schema, [], _at, [], _opts), do: :ok

  defp items_list(_schema, [], _at, errors, _opts),
    do: {:error, Enum.reverse(errors)}

  defp items_list(schema, [item | list], at, errors, opts) do
    case do_validate(schema, item, opts) do
      :ok ->
        items_list(schema, list, at + 1, errors, opts)

      {:error, reason} ->
        items_list(schema, list, at + 1, [{at, reason} | errors], opts)
    end
  end

  @spec items_tuple(
          list,
          nil | boolean | Xema.Schema.t(),
          list,
          integer,
          list,
          keyword
        ) :: result
  defp items_tuple(_schemas, _additonal_items, [], _at, [], _opts), do: :ok

  defp items_tuple(_schemas, _additonal_items, [], _at, errors, _opts),
    do: {:error, Enum.reverse(errors)}

  defp items_tuple([], false, [_ | list], at, errors, opts),
    do:
      items_tuple(
        [],
        false,
        list,
        at + 1,
        [
          {at, %{additional_items: false}} | errors
        ],
        opts
      )

  defp items_tuple([], true, _list, _at, [], _opts), do: :ok

  defp items_tuple([], true, _list, _at, errors, _opts),
    do: {:error, Enum.reverse(errors)}

  defp items_tuple([], schema, [item | list], at, errors, opts) do
    case do_validate(schema, item, opts) do
      :ok ->
        items_tuple([], schema, list, at + 1, errors, opts)

      {:error, reason} ->
        items_tuple([], schema, list, at + 1, [{at, reason} | errors], opts)
    end
  end

  defp items_tuple(
         [schema | schemas],
         additional_items,
         [item | list],
         at,
         errors,
         opts
       ) do
    case do_validate(schema, item, opts) do
      :ok ->
        items_tuple(schemas, additional_items, list, at + 1, errors, opts)

      {:error, reason} ->
        items_tuple(
          schemas,
          additional_items,
          list,
          at + 1,
          [
            {at, reason} | errors
          ],
          opts
        )
    end
  end

  @spec keys(Xema.Schema.t(), any) :: result
  defp keys(%{keys: nil}, _value), do: :ok

  defp keys(%{keys: :atoms}, map) do
    case map |> Map.keys() |> Enum.all?(&is_atom/1) do
      true -> :ok
      false -> {:error, %{keys: :atoms}}
    end
  end

  defp keys(%{keys: :strings}, map) do
    case map |> Map.keys() |> Enum.all?(&is_binary/1) do
      true -> :ok
      false -> {:error, %{keys: :strings}}
    end
  end

  @spec properties(Xema.Schema.t(), map, keyword) :: result
  defp properties(%{properties: nil}, map, _opts), do: {:ok, map}

  defp properties(%{properties: props}, map, opts) do
    do_properties(Map.to_list(props), map, %{}, opts)
  end

  @spec do_properties(list, map, map, keyword) :: result
  defp do_properties([], map, errors, _opts) when errors == %{}, do: {:ok, map}

  defp do_properties([], _map, errors, _opts),
    do: {:error, %{properties: errors}}

  defp do_properties([{prop, schema} | props], map, errors, opts) do
    with true <- has_key?(map, prop),
         {:ok, value} <- get_value(map, prop),
         :ok <- do_validate(schema, value, opts) do
      case has_key?(props, prop) do
        true -> do_properties(props, map, errors, opts)
        false -> do_properties(props, delete_property(map, prop), errors, opts)
      end
    else
      # The property is not in the map.
      false ->
        do_properties(props, delete_property(map, prop), errors, opts)

      {:error, reason} ->
        do_properties(
          props,
          Map.delete(map, prop),
          Map.put(errors, get_key(map, prop), reason),
          opts
        )
    end
  end

  @spec delete_property(map, String.t() | atom) :: map
  defp delete_property(map, prop) when is_map(map) and is_atom(prop) do
    case Map.has_key?(map, prop) do
      true -> Map.delete(map, prop)
      false -> Map.delete(map, Atom.to_string(prop))
    end
  end

  defp delete_property(map, prop) when is_map(map) and is_binary(prop) do
    case Map.has_key?(map, prop) do
      true -> Map.delete(map, prop)
      false -> Map.delete(map, to_existing_atom(prop))
    end
  end

  @spec required(Xema.Schema.t(), map) :: result
  defp required(%{required: nil}, _map), do: :ok

  defp required(%{required: required}, map) do
    case Enum.filter(required, fn key -> !has_key?(map, key) end) do
      [] ->
        :ok

      missing ->
        {
          :error,
          %{required: missing}
        }
    end
  end

  @spec size(Xema.Schema.t(), map) :: result
  defp size(%{min_properties: nil, max_properties: nil}, _map), do: :ok

  defp size(%{min_properties: min, max_properties: max}, map) do
    do_size(length(Map.keys(map)), min, max)
  end

  @spec do_size(number, number, number) :: result
  defp do_size(len, min, _max) when not is_nil(min) and len < min do
    {:error, %{min_properties: min}}
  end

  defp do_size(len, _min, max) when not is_nil(max) and len > max do
    {:error, %{max_properties: max}}
  end

  defp do_size(_len, _min, _max), do: :ok

  @spec patterns(Xema.Schema.t(), map, keyword) :: result
  defp patterns(%{pattern_properties: nil}, map, _opts), do: {:ok, map}

  defp patterns(%{pattern_properties: patterns}, map, opts) do
    props =
      for {pattern, schema} <- Map.to_list(patterns),
          key <- Map.keys(map),
          key_match?(pattern, key),
          do: {key, schema}

    do_properties(props, map, %{}, opts)
  end

  @spec key_match?(Regex.t(), String.t() | atom) :: boolean
  defp key_match?(regex, atom) when is_atom(atom) do
    key_match?(regex, to_string(atom))
  end

  defp key_match?(regex, string), do: Regex.match?(regex, string)

  @spec additionals(Xema.Schema.t(), map, keyword) :: result
  defp additionals(%{additional_properties: false}, map, _opts) do
    case Map.equal?(map, %{}) do
      true ->
        :ok

      false ->
        {
          :error,
          %{
            properties:
              map
              |> Map.keys()
              |> Enum.into(%{}, fn x -> {x, %{additional_properties: false}} end)
          }
        }
    end
  end

  defp additionals(%{additional_properties: schema}, map, opts)
       when is_map(schema) do
    result =
      Enum.reduce(map, %{}, fn {key, value}, acc ->
        case do_validate(schema, value, opts) do
          :ok -> acc
          {:error, reason} -> Map.put(acc, key, reason)
        end
      end)

    case result == %{} do
      true -> :ok
      false -> {:error, result}
    end
  end

  defp additionals(_schema, _map, _opts), do: :ok

  @spec dependencies(Xema.Schema.t(), map, keyword) :: result
  defp dependencies(%{dependencies: nil}, _map, _opts), do: :ok

  defp dependencies(%{dependencies: dependencies}, map, opts) do
    dependencies
    |> Map.to_list()
    |> Enum.filter(fn {key, _} -> has_key?(map, key) end)
    |> do_dependencies(map, opts)
  end

  @spec do_dependencies(list, map, keyword) :: result
  defp do_dependencies([], _map, _opts), do: :ok

  defp do_dependencies([{key, list} | tail], map, opts) when is_list(list) do
    with :ok <- do_dependencies_list(key, list, map, opts) do
      do_dependencies(tail, map, opts)
    end
  end

  # defp do_dependencies([{_key, true} | tail], map),
  #  do: do_dependencies(tail, map)
  #
  # defp do_dependencies([{key, false} | tail], map) do
  #  case Map.has_key?(map, key) do
  #    true -> {:error, %{dependencies: %{key => false}}}
  #    false -> do_dependencies(tail, map)
  #  end
  # end

  defp do_dependencies([{key, schema} | tail], map, opts) do
    case do_validate(schema, map, opts) do
      :ok ->
        do_dependencies(tail, map, opts)

      {:error, reason} ->
        {:error, %{dependencies: %{key => reason}}}
    end
  end

  @spec do_dependencies_list(String.t() | atom, list, map, keyword) :: result
  defp do_dependencies_list(_key, [], _map, _opts), do: :ok

  defp do_dependencies_list(key, [dependency | dependencies], map, opts) do
    case has_key?(map, dependency) do
      true ->
        do_dependencies_list(key, dependencies, map, opts)

      false ->
        {:error, %{dependencies: %{key => dependency}}}
    end
  end

  # Semantic validation of strings.
  @spec format(Xema.Schema.t(), any) :: result
  defp format(%{format: nil}, _str), do: :ok

  defp format(%{format: fmt}, str) when Format.supports(fmt) do
    case Format.is?(fmt, str) do
      true -> :ok
      false -> {:error, %{format: fmt, value: str}}
    end
  end

  defp format(_, _str), do: :ok
end
