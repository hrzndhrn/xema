defmodule Xema.SchemaError do
  defexception [:message]
end

defmodule Xema.Schema.Validator do
  @moduledoc false

  import Xema.Validator, only: [is_unique?: 1]

  @type result :: :ok | {:error, String.t()}

  @default_keys MapSet.new([
                  :all_of,
                  :allow,
                  :any_of,
                  :as,
                  :description,
                  :enum,
                  :id,
                  :not,
                  :one_of,
                  :schema,
                  :title,
                  :type
                ])

  @list_keys @default_keys
             |> MapSet.union(
               MapSet.new([
                 :items,
                 :max_items,
                 :min_items,
                 :additional_items,
                 :unique_items
               ])
             )

  @number_keys @default_keys
               |> MapSet.union(
                 MapSet.new([
                   :minimum,
                   :maximum,
                   :exclusive_maximum,
                   :exclusive_minimum,
                   :multiple_of
                 ])
               )

  @string_keys @default_keys
               |> MapSet.union(
                 MapSet.new([
                   :format,
                   :max_length,
                   :min_length,
                   :pattern
                 ])
               )

  @map_keys @default_keys
            |> MapSet.union(
              MapSet.new([
                :additional_properties,
                :dependencies,
                :keys,
                :max_properties,
                :min_properties,
                :pattern_properties,
                :properties,
                :required
              ])
            )

  @any_keys @number_keys
            |> MapSet.union(@string_keys)
            |> MapSet.union(@list_keys)
            |> MapSet.union(@map_keys)
            |> MapSet.union(
              MapSet.new([
                :definitions,
                :ref
              ])
            )

  @keys [
    any: @any_keys,
    boolean: @default_keys,
    float: @number_keys,
    integer: @number_keys,
    list: @list_keys,
    map: @map_keys,
    number: @number_keys,
    string: @string_keys
  ]

  @spec validate(atom, keyword) :: :ok | {:error, String.t()}
  def validate(_, []), do: :ok

  def validate(nil, type: nil), do: :ok

  def validate(:any, opts) do
    with :ok <- validate_keywords(:any, opts),
         :ok <- enum(:any, opts[:enum]),
         :ok <- schemas(opts, :all_of),
         :ok <- schemas(opts, :any_of),
         :ok <- string(opts, :ref),
         do: :ok
  end

  def validate(:boolean, opts) do
    with :ok <- validate_keywords(:boolean, opts) do
      :ok
    end
  end

  def validate(:list, opts) do
    with :ok <- validate_keywords(:list, opts),
         :ok <- items(opts[:items]),
         :ok <- non_negative_integer(:max_items, opts[:max_items]),
         :ok <- non_negative_integer(:min_items, opts[:min_items]),
         :ok <- additional_items(opts[:additional_items], opts[:items]) do
      :ok
    end
  end

  def validate(:map, opts) do
    with :ok <- validate_keywords(:map, opts),
         :ok <-
           additional_properties(
             opts[:additional_properties],
             opts[:properties],
             opts[:pattern_properties]
           ),
         :ok <- dependencies(opts[:dependencies]),
         :ok <- non_negative_integer(:max_properties, opts[:max_properties]),
         :ok <- non_negative_integer(:min_properties, opts[:min_properties]),
         :ok <- properties(opts[:properties]),
         :ok <- pattern_properties(opts[:pattern_properties]) do
      :ok
    end
  end

  def validate(type, opts)
      when type == :number or type == :integer or type == :float do
    with :ok <-
           ex_min_max(
             type,
             :exclusive_maximum,
             opts[:exclusive_maximum],
             opts[:maximum]
           ),
         :ok <-
           ex_min_max(
             type,
             :exclusive_minimum,
             opts[:exclusive_minimum],
             opts[:minimum]
           ),
         :ok <- min_max(type, :maximum, opts[:maximum]),
         :ok <- min_max(type, :minimum, opts[:minimum]),
         :ok <- multiple_of(type, opts[:multiple_of]),
         :ok <- validate_keywords(type, opts),
         :ok <- enum(type, opts[:enum]) do
      :ok
    end
  end

  def validate(:string, opts) do
    with :ok <- validate_keywords(:string, opts),
         :ok <- enum(:string, opts[:enum]),
         :ok <- non_negative_integer(:max_length, opts[:max_length]),
         :ok <- non_negative_integer(:min_length, opts[:min_length]),
         :ok <- regex(:pattern, opts[:pattern]) do
      :ok
    end
  end

  # Check if keyword value a string

  defp string(opts, key) do
    case opts[key] do
      nil -> :ok
      value when is_binary(value) -> :ok
      _ -> {:error, "The value for '#{key}' must be a string."}
    end
  end

  # Check for unsupported keywords.

  defp validate_keywords(type, opts) do
    case difference(type, opts) do
      [] ->
        :ok

      keywords ->
        {
          :error,
          "Keywords #{inspect(keywords)} are not supported by #{inspect(type)}."
        }
    end
  end

  defp difference(type, opts),
    do:
      opts
      |> Keyword.keys()
      |> MapSet.new()
      |> MapSet.difference(@keys[type])
      |> MapSet.to_list()

  # Check for a list

  defp schemas(opts, key) do
    case opts[key] do
      nil -> :ok
      items when is_list(items) -> :ok
      _ -> {:error, "#{key} has to be a list."}
    end
  end

  # Keyword: additional_items
  # The value of `additional_items` must be either a boolean or a schema.

  defp additional_items(nil, _), do: :ok

  defp additional_items(_, nil),
    do: {:error, "additional_items has no effect if items not set."}

  defp additional_items(_, items)
       when not is_list(items),
       do: {:error, "additional_items has no effect if items is not a list."}

  defp additional_items(_, _), do: :ok

  # Keyword: additional_properties
  # The value of `additional_properties` must be a boolean or a schema.

  defp additional_properties(nil, _, _), do: :ok

  defp additional_properties(_, nil, nil),
    do: {:error, "additional_properties has no effect if properties not set."}

  defp additional_properties(_, properties, nil)
       when not is_map(properties),
       do: {
         :error,
         "additional_properties has no effect if properties is not a map."
       }

  defp additional_properties(_, _, _), do: :ok

  # Keyword: dependencies
  # This keyword's value must be a map. Each property specifies a dependency.
  # Each dependency value must be an array or a valid schema.

  defp dependencies(nil), do: :ok

  defp dependencies(value) when is_map(value), do: :ok

  defp dependencies(_), do: {:error, "dependencies must be a map."}

  # Keyword: enum
  # The value of this keyword must be an array. This array should have at least
  # one element. Elements in the array should be unique.

  defp enum(_, nil), do: :ok

  defp enum(_, []), do: {:error, "enum can not be an empty list."}

  defp enum(type, value) when is_list(value) do
    case is_unique?(value) do
      false -> {:error, "enum must be unique."}
      true -> do_enum(type, value)
    end
  end

  defp enum(_, _), do: {:error, "enum must be a list."}

  defp do_enum(:any, _), do: :ok

  defp do_enum(:number, value) do
    case Enum.all?(value, fn item -> is_number(item) end) do
      true -> :ok
      false -> {:error, "Entries of enum have to be Integers or Floats."}
    end
  end

  defp do_enum(:integer, value) do
    case Enum.all?(value, fn item -> is_integer(item) end) do
      true -> :ok
      false -> {:error, "Entries of enum have to be Integers."}
    end
  end

  defp do_enum(:float, value) do
    case Enum.all?(value, fn item -> is_float(item) end) do
      true -> :ok
      false -> {:error, "Entries of enum have to be Floats."}
    end
  end

  defp do_enum(:string, value) do
    case Enum.all?(value, fn item -> is_binary(item) end) do
      true -> :ok
      false -> {:error, "Entries of enum have to be Strings."}
    end
  end

  # Keyword: exclusive_maximum
  # Draft-06: The value of `exclusive_maximum` must be number, representing an
  # exclusive upper limit for a numeric instance.
  # Draft-04: if `exclusive_maximum` has boolean value true, the instance is
  # valid if it is strictly lower than the value of `maximum`.
  #
  # Keyword: exclusive_minimum
  # Draft-06: The value of `exclusive_minimum` must be number, representing an
  # exclusive lower limit for a numeric instance.
  # Draft-04: if `exclusive_minimum` has boolean value true, the instance is
  # valid if it is strictly higher than the value of `maximum`.

  defp ex_min_max(_, _, nil, _), do: :ok

  defp ex_min_max(:integer, _, value, nil) when is_integer(value), do: :ok

  defp ex_min_max(:float, _, value, nil) when is_number(value), do: :ok

  defp ex_min_max(:number, _, value, nil) when is_number(value), do: :ok

  defp ex_min_max(_, _, value, maximum)
       when is_boolean(value) and is_number(maximum),
       do: :ok

  defp ex_min_max(_, :exclusive_maximum, value, _maximum)
       when is_boolean(value),
       do: {:error, "No maximum value found for exclusive_maximum."}

  defp ex_min_max(_, :exclusive_minimum, value, _maximum)
       when is_boolean(value),
       do: {:error, "No minimum value found for exclusive_minimum."}

  defp ex_min_max(:integer, keyword, value, nil),
    do: {:error, "Expected a integer for #{keyword}, got #{inspect(value)}"}

  defp ex_min_max(_, keyword, value, nil),
    do: {:error, "Expected a number for #{keyword}, got #{inspect(value)}"}

  defp ex_min_max(_, :exclusive_maximum, value, _maximum)
       when is_number(value),
       do: {:error, "The exclusive_maximum overwrites maximum."}

  defp ex_min_max(_, :exclusive_minimum, value, _maximum)
       when is_number(value),
       do: {:error, "The exclusive_minimum overwrites minimum."}

  defp ex_min_max(_, keyword, value, _maximum),
    do: {:error, "Expected a boolean for #{keyword}, got #{inspect(value)}"}

  # Keyword: items
  # The value of `items` MUST be either a valid JSON Schema or an array of
  # valid JSON Schemas.

  defp items(nil), do: :ok

  defp items(value)
       when is_list(value) or is_tuple(value) or is_atom(value) or is_map(value),
       do: :ok

  defp items(value),
    do:
      {:error, "Expected a schema or a list of schemas, got #{inspect(value)}."}

  # Keyword: maximum
  # The value of `maximum` must be a number, representing an inclusive upper
  # limit for a numeric instance.
  #
  # Keyword: minimum
  # The value of `minimum` must be a number, representing an inclusive upper
  # limit for a numeric instance.

  defp min_max(_, _, nil), do: :ok

  defp min_max(:number, _, value) when is_number(value), do: :ok

  defp min_max(:integer, _, value) when is_integer(value), do: :ok

  defp min_max(:float, _, value) when is_number(value), do: :ok

  defp min_max(:integer, keyword, value),
    do: {:error, "Expected an Integer for #{keyword}, got #{inspect(value)}."}

  defp min_max(_, keyword, value),
    do: {:error, "Expected a number for #{keyword}, got #{inspect(value)}."}

  # Keyword: multiple_of
  # The value of `multipleOf` must be a number, strictly greater than 0.

  defp multiple_of(_, nil), do: :ok

  defp multiple_of(:integer, value)
       when is_integer(value),
       do: do_multiple_of(value)

  defp multiple_of(:float, value)
       when is_number(value),
       do: do_multiple_of(value)

  defp multiple_of(:number, value)
       when is_number(value),
       do: do_multiple_of(value)

  defp multiple_of(:integer, value),
    do: {
      :error,
      "Expected an Integer for multiple_of, got #{inspect(value)}."
    }

  defp multiple_of(_, value),
    do: {
      :error,
      "Expected a number for multiple_of, got #{inspect(value)}."
    }

  @spec non_negative_integer(atom, any) :: result
  defp non_negative_integer(_, nil), do: :ok

  defp non_negative_integer(_, value)
       when is_integer(value) and value >= 0,
       do: :ok

  defp non_negative_integer(keyword, value),
    do: {
      :error,
      "Expected a non negative integer for #{keyword}, got #{inspect(value)}."
    }

  @spec properties(any) :: result
  defp properties(nil), do: :ok

  defp properties(value) when is_map(value) do
    value
    |> Map.keys()
    |> Enum.reduce_while(:ok, &property_key/2)
  end

  defp properties(value),
    do: {:error, "Expected a map for properties, got #{inspect(value)}."}

  @spec property_key(any, any) :: {:cont, :ok} | {:error, String.t()}
  defp property_key(key, _)
       when is_binary(key) or is_atom(key),
       do: {:cont, :ok}

  defp property_key(key, _),
    do: {
      :halt,
      {
        :error,
        "Expected a string or atom for key in properties, got #{inspect(key)}."
      }
    }

  @spec pattern_properties(any) :: result
  defp pattern_properties(nil), do: :ok

  defp pattern_properties(value) when is_map(value) do
    case value |> Map.keys() |> Enum.drop_while(&is_regex/1) do
      [] ->
        :ok

      [key | _] ->
        {
          :error,
          "Expected a regular expression for key in pattern_properties, got #{
            inspect(key)
          }."
        }
    end
  end

  defp pattern_properties(value),
    do:
      {:error, "Expected a map for pattern_properties, got #{inspect(value)}."}

  @spec regex(atom, any) :: result
  defp regex(_, nil), do: :ok

  defp regex(keyword, value) do
    case is_regex(value) do
      true ->
        :ok

      false ->
        {
          :error,
          "Expected a regular expression for #{keyword}, got #{inspect(value)}."
        }
    end
  end

  @spec is_regex(any) :: boolean
  defp is_regex(value) when is_binary(value) do
    case Regex.compile(value) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp is_regex(value) when is_atom(value), do: is_regex(Atom.to_string(value))

  defp is_regex(value) when is_map(value),
    do: Map.has_key?(value, :__struct__) && value.__struct__ == Regex

  defp is_regex(_), do: false

  @compile {:inline, do_multiple_of: 1}
  defp do_multiple_of(value) do
    case value > 0 do
      true -> :ok
      false -> {:error, "multiple_of must be strictly greater than 0."}
    end
  end
end
