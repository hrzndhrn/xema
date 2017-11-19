defmodule Xema.SchemaValidator do
  @moduledoc false

  @keys [
    float: %Xema.Float{} |> Map.keys() |> MapSet.new(),
    integer: %Xema.Number{} |> Map.keys() |> MapSet.new(),
    list: %Xema.List{} |> Map.keys() |> MapSet.new(),
    number: %Xema.Number{} |> Map.keys() |> MapSet.new(),
    map: %Xema.Map{} |> Map.keys() |> MapSet.new()
  ]

  @spec validate(atom, keyword) :: :ok
  def validate(:any, opts), do: opts
  def validate(:boolean, opts), do: opts

  def validate(:list, opts) do
    with :ok <- additional_items(opts[:additional_items], opts[:items]),
         :ok <- validate_keywords(:list, opts) do
      opts
    else
      error -> throw(error)
    end
  end

  def validate(:map, opts) do
    with :ok <-
           additional_properties(
             opts[:additional_properties],
             opts[:properties],
             opts[:pattern_properties]
           ),
         :ok <- validate_keywords(:map, opts) do
    else
      error -> throw(error)
    end
  end

  def validate(type, opts)
      when type == :number or type == :integer or type == :float do
    with :ok <- maximum(type, opts[:maximum]),
         :ok <- minimum(type, opts[:minimum]),
         :ok <- multiple_of(type, opts[:multiple_of]),
         :ok <- validate_keywords(type, opts) do
      opts
    else
      error -> throw(error)
    end
  end

  def validate(:string, opts), do: opts

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

  # Keyword: additional_items
  # The value of `additional_items` must be either a boolean or a schema.

  defp additional_items(nil, _), do: :ok

  defp additional_items(_, nil), do: {:error, "additional_items has no effect if items not set."}

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
       do: {:error, "additional_properties has no effect if properties is not a map."}

  defp additional_properties(_, _, _), do: :ok

  # Keyword: maximum
  # The value of `maximum` must be a number, representing an inclusive upper
  # limit for a numeric instance.

  defp maximum(_, nil), do: :ok

  defp maximum(:number, value)
       when is_integer(value) or is_float(value),
       do: :ok

  defp maximum(:integer, value)
       when is_integer(value),
       do: :ok

  defp maximum(:float, value)
       when is_integer(value) or is_float(value),
       do: :ok

  defp maximum(:integer, value),
    do: {:error, "Expected an Integer for maximum, got #{inspect(value)}."}

  defp maximum(_, value),
    do: {:error, "Expected an Integer or Float for maximum, got #{inspect(value)}."}

  # Keyword: minimum
  # The value of `minimum` must be a number, representing an inclusive upper
  # limit for a numeric instance.

  defp minimum(_, nil), do: :ok

  defp minimum(:number, value)
       when is_integer(value) or is_float(value),
       do: :ok

  defp minimum(:integer, value)
       when is_integer(value),
       do: :ok

  defp minimum(:float, value)
       when is_integer(value) or is_float(value),
       do: :ok

  defp minimum(:integer, value),
    do: {:error, "Expected an Integer for minimum, got #{inspect(value)}."}

  defp minimum(_, value),
    do: {:error, "Expected an Integer or Float for minimum, got #{inspect(value)}."}

  # Keyword: multiple_of
  # The value of `multipleOf` must be a number, strictly greater than 0.

  defp multiple_of(_, nil), do: :ok

  defp multiple_of(:integer, value)
       when is_integer(value),
       do: do_multiple_of(value)

  defp multiple_of(:float, value)
       when is_float(value) or is_integer(value),
       do: do_multiple_of(value)

  defp multiple_of(:number, value)
       when is_float(value) or is_integer(value),
       do: do_multiple_of(value)

  defp multiple_of(:integer, value),
    do:
      {
        :error,
        "Expected an Integer for multiple_of, got #{inspect(value)}."
      }

  defp multiple_of(_, value),
    do:
      {
        :error,
        "Expected an Integer or Float for multiple_of, got #{inspect(value)}."
      }

  @compile {:inline, do_multiple_of: 1}
  defp do_multiple_of(value) do
    case value > 0 do
      true -> :ok
      false -> {:error, "multiple_of must be strictly greater than 0."}
    end
  end
end
