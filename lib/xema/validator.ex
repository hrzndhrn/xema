defmodule Xema.Validator do
  @moduledoc """
  This module contains all validators to check data against a schema.
  """

  use Xema.Format

  import Xema.Utils

  alias Xema.Ref
  alias Xema.Schema

  @compile {
    :inline,
    do_validate: 3, get_type: 1, struct?: 1, struct?: 2, type?: 2, types: 2, validate_by: 4
  }

  @type result :: :ok | {:error, map}

  @types [
    :atom,
    :struct,
    :boolean,
    :float,
    :integer,
    :keyword,
    :list,
    :map,
    nil,
    :number,
    :string,
    :tuple
  ]

  @doc """
  A callback for custom validators. For an example see:
  [Custom validators](examples.html#custom-validator)
  """
  @callback validate(any) :: :ok | result

  @doc """
  Validates `data` against the given `schema`.
  """
  @spec validate(Xema.t() | Schema.t(), any) :: result
  def validate(schema, data), do: validate(schema, data, [])

  @doc false
  @spec validate(Xema.t() | Schema.t(), any, keyword) :: result
  def validate(%Schema{} = schema, data, opts),
    do: do_validate(schema, data, opts)

  def validate(%{schema: schema} = xema, data, opts),
    do:
      do_validate(
        schema,
        data,
        opts
        |> Keyword.put_new(:root, xema)
        |> Keyword.put_new(:master, xema)
      )

  @spec do_validate(Xema.t() | Xema.Schema.t(), any, keyword) :: result
  defp do_validate(%Schema{type: true}, _, _), do: :ok

  defp do_validate(%Schema{type: false}, _, _), do: {:error, %{type: false}}

  defp do_validate(%Schema{type: types} = schema, value, opts) when is_list(types) do
    with {:ok, type} <- types(schema, value),
         :ok <- validate_by(:default, schema, value, opts),
         :ok <- validate_by(type, schema, value, opts),
         :ok <- custom_validator(schema, value),
         do: :ok
  end

  defp do_validate(%Schema{type: :any, ref: nil} = schema, value, opts) do
    with type <- get_type(value),
         :ok <- validate_by(:default, schema, value, opts),
         :ok <- validate_by(type, schema, value, opts),
         :ok <- custom_validator(schema, value),
         do: :ok
  end

  defp do_validate(%Schema{type: :any, ref: ref}, value, opts), do: Ref.validate(ref, value, opts)

  defp do_validate(%Schema{type: type} = schema, value, opts) do
    with :ok <- type(schema, value),
         :ok <- validate_by(:default, schema, value, opts),
         :ok <- validate_by(type, schema, value, opts),
         :ok <- custom_validator(schema, value),
         do: :ok
  end

  defp do_validate(%{schema: schema}, value, opts),
    do: do_validate(schema, value, opts)

  defp validate_by(:default, schema, value, opts) do
    with :ok <- enum(schema, value),
         :ok <- not_(schema, value, opts),
         :ok <- all_of(schema, value, opts),
         :ok <- any_of(schema, value, opts),
         :ok <- one_of(schema, value, opts),
         :ok <- const(schema, value),
         :ok <- if_then_else(schema, value, opts),
         do: :ok
  end

  defp validate_by(:string, schema, value, _opts) do
    with :ok <- min_length(schema, value),
         :ok <- max_length(schema, value),
         :ok <- pattern(schema, value),
         :ok <- format(schema, value),
         do: :ok
  end

  defp validate_by(nil, _schema, nil, _opts), do: :ok

  defp validate_by(nil, schema, value, _opts),
    do: {:error, %{value: value, type: schema.type}}

  defp validate_by(:tuple, schema, value, opts),
    do: validate_by(:list, schema, value, opts)

  defp validate_by(:list, schema, value, opts) do
    with :ok <- min_items(schema, value),
         :ok <- max_items(schema, value),
         :ok <- unique(schema, value),
         :ok <- items(schema, value, opts),
         :ok <- contains(schema, value, opts),
         do: :ok
  end

  defp validate_by(:struct, schema, value, opts) do
    with :ok <- module(schema, value),
         :ok <- validate_by(:map, schema, value, opts),
         do: :ok
  end

  defp validate_by(:map, schema, value, opts) do
    with :ok <- size(schema, value),
         :ok <- keys(schema, value),
         :ok <- required(schema, value),
         :ok <- property_names(schema, value, opts),
         :ok <- dependencies(schema, value, opts),
         {:ok, patts_rest} <- patterns(schema, value, opts),
         {:ok, props_rest} <- properties(schema, value, opts),
         value <- intersection(props_rest, patts_rest),
         :ok <- additionals(schema, value, opts),
         do: :ok
  end

  defp validate_by(:keyword, schema, value, opts) do
    with :ok <- dependencies(schema, value, opts),
         value <- Enum.into(value, %{}),
         :ok <- size(schema, value),
         :ok <- keys(schema, value),
         :ok <- required(schema, value),
         :ok <- property_names(schema, value, opts),
         {:ok, patts_rest} <- patterns(schema, value, opts),
         {:ok, props_rest} <- properties(schema, value, opts),
         value <- intersection(props_rest, patts_rest),
         :ok <- additionals(schema, value, opts),
         do: :ok
  end

  defp validate_by(:boolean, schema, value, _opts) do
    case is_boolean(value) do
      true -> :ok
      false -> {:error, %{value: value, type: schema.type}}
    end
  end

  defp validate_by(:integer, schema, value, opts),
    do: validate_by(:number, schema, value, opts)

  defp validate_by(:float, schema, value, opts),
    do: validate_by(:number, schema, value, opts)

  defp validate_by(:number, schema, value, opts) do
    with :ok <- minimum(schema, value),
         :ok <- maximum(schema, value),
         :ok <- exclusive_maximum(schema, value),
         :ok <- exclusive_minimum(schema, value),
         :ok <- multiple_of(schema, value),
         :ok <- validate_by(:default, schema, value, opts),
         do: :ok
  end

  defp validate_by(:atom, _, _, _), do: :ok

  #
  # Schema type handling
  #

  defp get_type([]), do: :list

  defp get_type(value),
    do: Enum.find(@types, fn type -> type?(type, value) end)

  @spec type(Xema.Schema.t() | atom, any) :: result
  defp type(%{type: type}, value) do
    case type?(type, value) do
      true -> :ok
      false -> {:error, %{type: type, value: value}}
    end
  end

  @spec type?(atom, any) :: boolean
  defp type?(:any, _value), do: true
  defp type?(:atom, value), do: is_atom(value)
  defp type?(:boolean, value), do: is_boolean(value)
  defp type?(:string, value), do: is_binary(value)
  defp type?(:tuple, value), do: is_tuple(value)
  defp type?(:keyword, value), do: Keyword.keyword?(value)
  defp type?(:number, value), do: is_number(value)
  defp type?(:integer, value), do: is_integer(value)
  defp type?(:float, value), do: is_float(value)
  defp type?(:map, value), do: is_map(value)
  defp type?(:list, value), do: is_list(value)
  defp type?(:struct, value), do: is_map(value) && struct?(value)
  defp type?(nil, nil), do: true
  defp type?(_, _), do: false

  @spec struct?(any) :: boolean
  defp struct?(%_{}), do: true

  defp struct?(_), do: false

  @spec struct?(any, atom) :: boolean
  defp struct?(%module{}, module), do: true

  defp struct?(_, _), do: false

  @spec types(Schema.t(), any) :: {:ok, atom} | {:error, map}
  defp types(%{type: list}, value) do
    case Enum.find(list, :not_found, fn type -> type?(type, value) end) do
      :not_found -> {:error, %{type: list, value: value}}
      found -> {:ok, found}
    end
  end

  #
  # Validators
  #

  @spec const(Xema.Schema.t(), any) :: result
  defp const(%{const: nil}, _value), do: :ok

  defp const(%{const: :__nil__}, nil), do: :ok

  defp const(%{const: :__nil__}, value),
    do: {:error, %{const: nil, value: value}}

  defp const(%{const: const}, const), do: :ok

  defp const(%{const: const}, value),
    do: {:error, %{const: const, value: value}}

  @spec if_then_else(Xema.t() | Schema.t(), any, keyword) :: result
  defp if_then_else(%{if: nil}, _value, _opts), do: :ok
  defp if_then_else(%{then: nil, else: nil}, _value, _opts), do: :ok

  defp if_then_else(%{if: schema_if, then: schema_then, else: schema_else}, value, opts) do
    case Xema.valid?(schema_if, value) do
      true ->
        if_then_else(:then, schema_then, value, opts)

      false ->
        if_then_else(:else, schema_else, value, opts)
    end
  end

  @spec if_then_else(atom, Schema.t() | nil, any) :: result
  defp if_then_else(_key, nil, _value, _opts), do: :ok

  defp if_then_else(key, schema, value, opts) do
    case do_validate(schema, value, opts) do
      :ok -> :ok
      {:error, reason} -> {:error, Map.new([{key, reason}])}
    end
  end

  @spec property_names(Xema.t() | Schema.t(), map, keyword) :: result
  defp property_names(%{property_names: nil}, _map, _opts), do: :ok

  defp property_names(%{property_names: schema}, map, opts) do
    map
    |> Map.keys()
    |> Enum.reduce([], fn
      key, acc when is_binary(key) ->
        case do_validate(schema, key, opts) do
          :ok -> acc
          {:error, reason} -> [{key, reason} | acc]
        end

      key, acc when is_atom(key) ->
        case do_validate(schema, Atom.to_string(key), opts) do
          :ok -> acc
          {:error, reason} -> [{key, reason} | acc]
        end

      _, acc ->
        acc
    end)
    |> case do
      [] -> :ok
      errors -> {:error, %{value: Map.keys(map), property_names: Enum.reverse(errors)}}
    end
  end

  @spec enum(Xema.Schema.t(), any) :: result
  defp enum(%{enum: nil}, _element), do: :ok

  defp enum(%{enum: enum}, value) do
    case Enum.member?(enum, value) do
      true -> :ok
      false -> {:error, %{enum: enum, value: value}}
    end
  end

  @spec module(Schema.t(), any) :: result
  defp module(%{module: nil}, _val), do: :ok

  defp module(%{module: module}, val) do
    case struct?(val, module) do
      true -> :ok
      false -> {:error, %{module: module, value: val}}
    end
  end

  @spec not_(Xema.Schema.t(), any, keyword) :: result
  defp not_(%{not: nil}, _value, _opts), do: :ok

  defp not_(%{not: schema}, value, opts) do
    case do_validate(schema, value, opts) do
      :ok -> {:error, %{not: :ok, value: value}}
      _ -> :ok
    end
  end

  @spec any_of(Xema.Schema.t(), any, keyword) :: result
  defp any_of(%{any_of: nil}, _value, _opts), do: :ok

  defp any_of(%{any_of: schemas}, value, opts) do
    case do_any_of(schemas, value, opts) do
      :ok ->
        :ok

      {:error, errors} ->
        {:error, %{any_of: Enum.reverse(errors), value: value}}
    end
  end

  @spec do_any_of(list, any, keyword, [map]) :: :ok | {:error, list(map)}
  defp do_any_of(schemas, value, opts, errors \\ [])

  defp do_any_of([], _value, _opts, errors), do: {:error, errors}

  defp do_any_of([schema | schemas], value, opts, errors) do
    with {:error, error} <- do_validate(schema, value, opts) do
      do_any_of(schemas, value, opts, [error | errors])
    end
  end

  @spec all_of(Xema.Schema.t(), any, keyword) :: result
  defp all_of(%{all_of: nil}, _value, _opts), do: :ok

  defp all_of(%{all_of: schemas}, value, opts) do
    with {:error, errors} <- do_all_of(schemas, value, opts) do
      {:error, %{all_of: errors, value: value}}
    end
  end

  @spec do_all_of(list, any, keyword, [map]) :: result
  defp do_all_of(schemas, value, opts, errors \\ [])

  defp do_all_of([], _value, _opts, []), do: :ok

  defp do_all_of([], _value, _opts, errors),
    do: {:error, Enum.reverse(errors)}

  defp do_all_of([schema | schemas], value, opts, errors) do
    case do_validate(schema, value, opts) do
      :ok ->
        do_all_of(schemas, value, opts, errors)

      {:error, error} ->
        do_all_of(schemas, value, opts, [error | errors])
    end
  end

  @spec one_of(Xema.Schema.t(), any, keyword) :: result
  defp one_of(%{one_of: nil}, _value, _opts), do: :ok

  defp one_of(%{one_of: schemas}, value, opts) do
    case do_one_of(schemas, value, opts) do
      %{success: [], errors: errors} ->
        {:error, %{one_of: {:error, Enum.reverse(errors)}, value: value}}

      %{success: [_]} ->
        :ok

      %{success: success} ->
        {:error, %{one_of: {:ok, Enum.reverse(success)}, value: value}}
    end
  end

  @spec do_one_of(list, any, keyword) :: %{errors: [map], success: [map]}
  defp do_one_of(schemas, value, opts),
    do:
      schemas
      |> Enum.with_index()
      |> Enum.reduce(
        %{errors: [], success: []},
        fn {schema, index}, %{errors: errors, success: success} ->
          case do_validate(schema, value, opts) do
            :ok ->
              %{errors: errors, success: [index | success]}

            {:error, error} ->
              %{errors: [error | errors], success: success}
          end
        end
      )

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
    do: {:error, %{value: value, minimum: minimum, exclusive_minimum: exclusive}}

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
    do: {:error, %{value: value, maximum: maximum, exclusive_maximum: exclusive}}

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

  @spec min_length(Xema.Schema.t(), String.t()) :: result
  defp min_length(%{min_length: nil}, _), do: :ok

  defp min_length(%{min_length: min}, value) do
    len = String.length(value)

    case len >= min do
      true -> :ok
      false -> {:error, %{value: value, min_length: min}}
    end
  end

  @spec max_length(Xema.Schema.t(), String.t()) :: result
  defp max_length(%{max_length: nil}, _), do: :ok

  defp max_length(%{max_length: max}, value) do
    len = String.length(value)

    case len <= max do
      true -> :ok
      false -> {:error, %{value: value, max_length: max}}
    end
  end

  @spec pattern(Xema.Schema.t(), String.t()) :: result
  defp pattern(%{pattern: nil}, _string), do: :ok

  defp pattern(%{pattern: pattern}, string) do
    case Regex.match?(pattern, string) do
      true -> :ok
      false -> {:error, %{value: string, pattern: pattern}}
    end
  end

  @spec min_items(Xema.Schema.t(), list | tuple) :: result
  defp min_items(%{min_items: nil}, _), do: :ok

  defp min_items(%{min_items: min}, val) do
    case size(val) >= min do
      true -> :ok
      false -> {:error, %{value: val, min_items: min}}
    end
  end

  @spec max_items(Xema.Schema.t(), list | tuple) :: result
  defp max_items(%{max_items: nil}, _list), do: :ok

  defp max_items(%{max_items: max}, val) do
    case size(val) <= max do
      true -> :ok
      false -> {:error, %{value: val, max_items: max}}
    end
  end

  @spec unique(Xema.Schema.t(), list | tuple) :: result
  defp unique(%{unique_items: nil}, _list), do: :ok

  defp unique(%{unique_items: true}, list) when is_list(list) do
    case unique?(list) do
      true -> :ok
      false -> {:error, %{value: list, unique_items: true}}
    end
  end

  defp unique(%{unique_items: true}, tuple) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> unique?()
    |> case do
      true -> :ok
      false -> {:error, %{value: tuple, unique_items: true}}
    end
  end

  @spec unique?(list, map) :: boolean
  defp unique?(list, set \\ %{})
  defp unique?([], _), do: true

  defp unique?([h | t], set) do
    case set do
      %{^h => true} -> false
      _ -> unique?(t, Map.put(set, h, true))
    end
  end

  @spec contains(Schema.t(), any, keyword) :: result
  defp contains(%{contains: nil}, _, _), do: :ok

  defp contains(%{contains: _} = schema, tuple, opts) when is_tuple(tuple) do
    with {:error, reason} <- contains(schema, Tuple.to_list(tuple), opts) do
      {:error, %{reason | value: tuple}}
    end
  end

  defp contains(%{contains: schema}, list, opts) when is_list(list) do
    errors =
      list
      |> Enum.with_index()
      |> Enum.reduce([], fn {value, index}, acc ->
        case do_validate(schema, value, opts) do
          :ok -> acc
          {:error, reason} -> [{index, reason} | acc]
        end
      end)

    case length(errors) < length(list) do
      true -> :ok
      false -> {:error, %{value: list, contains: Enum.reverse(errors)}}
    end
  end

  @spec items(Schema.t(), list | tuple, keyword) :: result
  defp items(%{items: nil}, _list, _opts), do: :ok

  defp items(schema, tuple, opts) when is_tuple(tuple),
    do: items(schema, Tuple.to_list(tuple), opts)

  defp items(%{items: items} = schema, list, opts)
       when is_list(items),
       do:
         items_tuple(
           items,
           Map.get(schema, :additional_items, true),
           Enum.with_index(list),
           [],
           opts
         )

  defp items(%{items: items}, list, opts),
    do: items_list(items, Enum.with_index(list), [], opts)

  @spec items_list(Xema.Schema.t(), [{any, integer}], list, keyword) :: result

  defp items_list(%{type: false}, [], _, _), do: :ok
  defp items_list(%{type: false}, _, _, _), do: {:error, %{type: false}}
  defp items_list(%{type: true}, _, _, _), do: :ok

  defp items_list(_schema, [], [], _opts), do: :ok

  defp items_list(_schema, [], errors, _opts),
    do: {:error, %{items: Enum.reverse(errors)}}

  defp items_list(schema, [{item, index} | list], errors, opts) do
    case do_validate(schema, item, opts) do
      :ok ->
        items_list(schema, list, errors, opts)

      {:error, reason} ->
        items_list(schema, list, [{index, reason} | errors], opts)
    end
  end

  @spec items_tuple(
          list,
          nil | boolean | Xema.Schema.t(),
          [{any, integer}],
          list,
          keyword
        ) :: result
  defp items_tuple(_schemas, _additonal_items, [], [], _opts), do: :ok

  defp items_tuple(_schemas, _additonal_items, [], errors, _opts),
    do: {:error, %{items: Enum.reverse(errors)}}

  defp items_tuple([], false, [{_, index} | list], errors, opts),
    do:
      items_tuple(
        [],
        false,
        list,
        [{index, %{additional_items: false}} | errors],
        opts
      )

  defp items_tuple([], additional_items, _list, [], _opts)
       when additional_items in [nil, true],
       do: :ok

  defp items_tuple([], additional_items, _list, errors, _opts)
       when additional_items in [nil, true],
       do: {:error, %{items: Enum.reverse(errors)}}

  defp items_tuple([], schema, [{item, index} | list], errors, opts) do
    case do_validate(schema, item, opts) do
      :ok ->
        items_tuple([], schema, list, errors, opts)

      {:error, reason} ->
        items_tuple([], schema, list, [{index, reason} | errors], opts)
    end
  end

  defp items_tuple(
         [schema | schemas],
         additional_items,
         [{item, index} | list],
         errors,
         opts
       ) do
    case do_validate(schema, item, opts) do
      :ok ->
        items_tuple(schemas, additional_items, list, errors, opts)

      {:error, reason} ->
        items_tuple(
          schemas,
          additional_items,
          list,
          [{index, reason} | errors],
          opts
        )
    end
  end

  @spec keys(Xema.Schema.t(), any) :: result
  defp keys(%{keys: nil}, _value), do: :ok

  defp keys(%{keys: :atoms}, map) do
    case map |> Map.keys() |> Enum.all?(&is_atom/1) do
      true -> :ok
      false -> {:error, %{keys: :atoms, value: map}}
    end
  end

  defp keys(%{keys: :strings}, map) do
    case map |> Map.keys() |> Enum.all?(&is_binary/1) do
      true -> :ok
      false -> {:error, %{keys: :strings, value: map}}
    end
  end

  @spec properties(Xema.Schema.t(), map, keyword) :: {:ok, map} | {:error, map}
  defp properties(%{properties: nil}, map, _opts), do: {:ok, map}

  defp properties(%{properties: props}, map, opts),
    do: do_properties(Map.to_list(props), map, %{}, opts)

  @spec do_properties(list, map, map, keyword) :: result
  defp do_properties([], map, errors, _opts) when errors == %{}, do: {:ok, map}

  defp do_properties([], _map, errors, _opts),
    do: {:error, %{properties: errors}}

  defp do_properties([{prop, schema} | props], map, errors, opts) do
    with {:ok, value} <- Map.fetch(map, prop),
         :ok <- do_validate(schema, value, opts) do
      # The list `props` can contain multiple schemas for the same value.
      # The value will be just deleted if one schema is available.
      # Multiple schemas are coming from `pattern_properties`.
      map =
        case has_key?(props, prop) do
          true -> map
          false -> Map.delete(map, prop)
        end

      do_properties(props, map, errors, opts)
    else
      # The property is not in the map.
      :error ->
        do_properties(props, map, errors, opts)

      {:error, reason} ->
        do_properties(
          props,
          Map.delete(map, prop),
          Map.put(errors, prop, reason),
          opts
        )
    end
  end

  @spec required(Xema.Schema.t(), map) :: result
  defp required(%{required: nil}, _map), do: :ok

  defp required(%{required: required}, map) do
    case Enum.filter(required, fn key -> !Map.has_key?(map, key) end) do
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
    do_size(length(Map.keys(map)), min, max, map)
  end

  @spec do_size(number, number, number, map) :: result
  defp do_size(len, min, _max, map) when not is_nil(min) and len < min do
    {:error, %{min_properties: min, value: map}}
  end

  defp do_size(len, _min, max, map) when not is_nil(max) and len > max do
    {:error, %{max_properties: max, value: map}}
  end

  defp do_size(_len, _min, _max, _map), do: :ok

  @spec patterns(Xema.Schema.t(), map, keyword) :: {:ok, map} | {:error, map}
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
              |> Enum.into(%{}, fn x ->
                {x, %{additional_properties: false}}
              end)
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
      false -> {:error, %{properties: result}}
    end
  end

  defp additionals(_schema, _map, _opts), do: :ok

  @spec dependencies(Xema.Schema.t(), map, keyword) :: result
  defp dependencies(%{dependencies: nil}, _map, _opts), do: :ok

  defp dependencies(%{dependencies: dependencies}, map, opts) do
    dependencies
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

  # Custom validator
  @spec custom_validator(Schema.t(), any) :: result
  defp custom_validator(%{validator: validator}, value)
       when is_function(validator, 1) do
    with {:error, reason} <- apply(validator, [value]) do
      {:error, %{validator: reason, value: value}}
    end
  end

  defp custom_validator(%{validator: {module, validator}}, value) do
    with {:error, reason} <- apply(module, validator, [value]) do
      {:error, %{validator: reason, value: value}}
    end
  end

  defp custom_validator(%{validator: behaviour}, value)
       when not is_nil(behaviour) and is_atom(behaviour) do
    with {:error, reason} <- apply(behaviour, :validate, [value]) do
      {:error, %{validator: reason, value: value}}
    end
  end

  defp custom_validator(_, _), do: :ok

  # Returns a map containing only keys that `map_1` and `map_2` have in common.
  # Values for the returned map are taken from `map_2`.
  @spec intersection(map, map) :: map
  defp intersection(map_1, map_2) when is_map(map_1) and is_map(map_2),
    do:
      for(
        key <- Map.keys(map_1),
        true == Map.has_key?(map_2, key),
        into: %{},
        do: {key, Map.get(map_2, key)}
      )
end
