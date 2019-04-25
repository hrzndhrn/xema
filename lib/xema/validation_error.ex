defmodule Xema.ValidationError do
  @moduledoc """
  Raised when a validation fails.
  """

  alias Xema.ValidationError

  defexception [:message, :reason]

  @impl true
  def exception(error) do
    %ValidationError{reason: error, message: format_error(error)}
  rescue
    error ->
      %ValidationError{reason: error, message: "Unexpected error."}
  end

  def format_error({:error, error}), do: format_error(error)

  def format_error(error),
    do:
      error
      |> travers_errors([], &format_error/3)
      |> Enum.reverse()
      |> Enum.join("\n")

  def travers_errors(error, acc, fun), do: travers_errors(error, acc, fun, [])

  defp travers_errors(%{properties: properties} = error, acc, fun, path),
    do:
      Enum.reduce(
        properties,
        fun.(error, path, acc),
        fn {key, value}, acc -> travers_errors(value, acc, fun, path ++ [key]) end
      )

  defp travers_errors(%{items: items} = error, acc, fun, path),
    do:
      Enum.reduce(
        items,
        fun.(error, path, acc),
        fn {key, value}, acc -> travers_errors(value, acc, fun, path ++ [key]) end
      )

  defp travers_errors(error, acc, fun, path), do: fun.(error, path, acc)

  defp format_error(%{minimum: minimum, exclusive_minimum: true, value: minimum}, path, acc)
       when not is_nil(minimum) do
    msg = "Value #{inspect(minimum)} equals exclusive minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{exclusive_minimum: minimum, value: minimum}, path, acc) do
    msg = "Value #{inspect(minimum)} equals exclusive minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{exclusive_minimum: minimum, value: value}, path, acc)
       when is_number(minimum) do
    msg = "Value #{inspect(value)} is less than minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{minimum: minimum, value: value}, path, acc) when not is_nil(minimum) do
    msg = "Value #{inspect(value)} is less than minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{maximum: maximum, exclusive_maximum: true, value: maximum}, path, acc)
       when not is_nil(maximum) do
    msg = "Value #{inspect(maximum)} equals exclusive maximum value of #{inspect(maximum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{exclusive_maximum: maximum, value: maximum}, path, acc) do
    msg = "Value #{inspect(maximum)} equals exclusive maximum value of #{inspect(maximum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{exclusive_maximum: maximum, value: value}, path, acc) do
    msg = "Value #{inspect(value)} exceeds maximum value of #{inspect(maximum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{maximum: maximum, value: value}, path, acc) do
    msg = "Value #{inspect(value)} exceeds maximum value of #{inspect(maximum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{min_length: min, value: value}, path, acc) do
    msg = "Expected minimum length of #{inspect(min)}, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{multiple_of: multiple_of, value: value}, path, acc) do
    msg = "Value #{inspect(value)} is not a multiple of #{inspect(multiple_of)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{enum: enum, value: value}, path, acc) when not is_nil(enum) do
    msg = "Value #{inspect(value)} is not defined in enum"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{keys: keys, value: value}, path, acc) when not is_nil(keys) do
    msg = "Expected #{inspect(keys)} as key, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{min_properties: min, value: value}, path, acc) when not is_nil(min) do
    msg = "Expected at least #{inspect(min)} properties, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{max_properties: max, value: value}, path, acc) when not is_nil(max) do
    msg = "Expected at most #{inspect(max)} properties, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{additional_properties: false}, path, acc) do
    msg = "Expected only defined properties, got key #{inspect(path)}."
    [msg | acc]
  end

  defp format_error(%{additional_items: false}, path, acc) do
    msg = "Unexpected additional item"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{contains: errors}, path, acc) do
    msg = "No items match contains#{at_path(path)}"

    errors =
      errors
      |> Enum.map(fn {_, reason} -> "  #{format_error(reason, [], [])}" end)
      |> Enum.join("\n")

    ["#{msg}\n#{errors}" | acc]
  end

  defp format_error(%{required: required}, path, acc) when is_list(required) do
    msg = "Required properties are missing: #{inspect(required)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{property_names: names, value: value}, path, acc) when not is_nil(names) do
    msg = "Invalid property names: #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{dependencies: deps}, path, acc) when not is_nil(deps) do
    msg =
      deps
      |> Enum.reduce([], fn
        {key, reason}, acc when is_map(reason) ->
          sub_msg =
            reason
            |> format_error(path, [])
            |> Enum.map(fn str -> "  #{str}" end)
            |> Enum.reverse()
            |> Enum.join("\n")

          ["Dependencies for #{inspect(key)} failed:\n#{sub_msg}" | acc]

        {key, reason}, acc ->
          [
            "Dependencies for #{inspect(key)} failed#{at_path(path)}" <>
              " Missing required key #{inspect(reason)}."
            | acc
          ]
      end)
      |> Enum.reverse()
      |> Enum.join("\n")

    [msg | acc]
  end

  defp format_error(%{min_items: min, value: value}, path, acc) when not is_nil(min) do
    msg = "Expected at least #{inspect(min)} items, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{max_items: max, value: value}, path, acc) when not is_nil(max) do
    msg = "Expected at most #{inspect(max)} items, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{unique_items: true, value: value}, path, acc) do
    msg = "Expected unique items, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{type: type, value: value}, path, acc) do
    msg = "Expected #{inspect(type)}, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{type: false}, path, acc) do
    msg = "Schema always fails validation"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{properties: _}, _path, acc), do: acc

  defp format_error(%{items: _}, _path, acc), do: acc

  defp format_error(_error, path, acc) do
    msg = "Unexpected error"
    [msg <> at_path(path) | acc]
  end

  defp at_path([]), do: "."

  defp at_path(path), do: ", at #{inspect(path)}."
end
