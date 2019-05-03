defmodule Xema.ValidationError do
  @moduledoc """
  Raised when a validation fails.
  """

  alias Xema.ValidationError

  defexception [:message, :reason]

  # TODO: remove all when's

  @impl true
  def exception(error) do
    %ValidationError{reason: error, message: format_error(error)}
  rescue
    error ->
      # Exception.format(:error, error, __STACKTRACE__) |>IO.puts
      %ValidationError{reason: error, message: "Unexpected error."}
  end

  def format_error({:error, error}), do: format_error(error)

  def format_error(error),
    do:
      error
      |> travers_errors([], &format_error/3)
      |> Enum.reverse()
      |> Enum.join("\n")

  def travers_errors(error, acc, fun, opts \\ [])

  def travers_errors(error, acc, fun, []), do: travers_errors(error, acc, fun, path: [])

  def travers_errors(%{properties: properties} = error, acc, fun, opts),
    do:
      Enum.reduce(
        properties,
        fun.(error, opts[:path], acc),
        fn {key, value}, acc -> travers_errors(value, acc, fun, path: opts[:path] ++ [key]) end
      )

  def travers_errors(%{items: items} = error, acc, fun, opts),
    do:
      Enum.reduce(
        items,
        fun.(error, opts[:path], acc),
        fn {key, value}, acc -> travers_errors(value, acc, fun, path: opts[:path] ++ [key]) end
      )

  def travers_errors(error, acc, fun, opts), do: fun.(error, opts[:path], acc)

  defp format_error(%{minimum: minimum, exclusive_minimum: true, value: value}, path, acc)
       when minimum == value do
    # The guard is used to match values of different types (integer, float).
    msg = "Value #{inspect(value)} equals exclusive minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{minimum: minimum, exclusive_minimum: true, value: value}, path, acc) do
    msg = "Value #{inspect(value)} is less than minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{exclusive_minimum: minimum, value: minimum}, path, acc) do
    msg = "Value #{inspect(minimum)} equals exclusive minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{exclusive_minimum: minimum, value: value}, path, acc) do
    msg = "Value #{inspect(value)} is less than minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{minimum: minimum, value: value}, path, acc) do
    msg = "Value #{inspect(value)} is less than minimum value of #{inspect(minimum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{maximum: maximum, exclusive_maximum: true, value: value}, path, acc)
       when maximum == value do
    # The guard is used to match values of different types (integer, float).
    msg = "Value #{inspect(value)} equals exclusive maximum value of #{inspect(maximum)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{maximum: maximum, exclusive_maximum: true, value: value}, path, acc) do
    msg = "Value #{inspect(value)} exceeds maximum value of #{inspect(maximum)}"
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

  defp format_error(%{max_length: max, value: value}, path, acc) do
    msg = "Expected maximum length of #{inspect(max)}, got #{inspect(value)}"
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

  defp format_error(%{enum: _enum, value: value}, path, acc) do
    msg = "Value #{inspect(value)} is not defined in enum"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{keys: keys, value: value}, path, acc) do
    msg = "Expected #{inspect(keys)} as key, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{min_properties: min, value: value}, path, acc) do
    msg = "Expected at least #{inspect(min)} properties, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{max_properties: max, value: value}, path, acc) do
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

  defp format_error(%{format: format, value: value}, path, acc) do
    msg = "String #{inspect(value)} does not validate against format #{inspect(format)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{then: errors}, path, acc) do
    msg = "Schema for then does not match#{at_path(path)}\n"
    errors = errors |> format_error() |> indent()
    [msg <> errors | acc]
  end

  defp format_error(%{else: errors}, path, acc) do
    msg = "Schema for else does not match#{at_path(path)}\n"
    errors = errors |> format_error() |> indent()
    [msg <> errors | acc]
  end

  defp format_error(%{not: :ok, value: value}, path, acc) do
    msg = "Value is valid against schema from not, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{contains: errors}, path, acc) do
    msg = ["No items match contains#{at_path(path)}"]

    errors =
      errors
      |> Enum.map(fn {index, reason} ->
        travers_errors(reason, [], &format_error/3, path: path ++ [index])
      end)
      |> Enum.reverse()
      |> indent()

    Enum.concat([errors, msg, acc])
  end

  defp format_error(%{any_of: errors}, path, acc) do
    msg = ["No match of any schema" <> at_path(path)]

    errors =
      errors
      |> Enum.flat_map(fn reason ->
        reason |> travers_errors([], &format_error/3, path: path) |> Enum.reverse()
      end)
      |> Enum.reverse()
      |> indent()

    Enum.concat([errors, msg, acc])
  end

  defp format_error(%{all_of: errors}, path, acc) do
    msg = ["No match of all schema#{at_path(path)}"]

    errors =
      errors
      |> Enum.map(fn reason ->
        travers_errors(reason, [], &format_error/3, path: path)
      end)
      |> Enum.reverse()
      |> indent()

    Enum.concat([errors, msg, acc])
  end

  defp format_error(%{one_of: {:error, errors}}, path, acc) do
    msg = ["No match of any schema#{at_path(path)}"]

    errors =
      errors
      |> Enum.map(fn reason ->
        travers_errors(reason, [], &format_error/3, path: path)
      end)
      |> Enum.reverse()
      |> indent()

    Enum.concat([errors, msg, acc])
  end

  defp format_error(%{one_of: {:ok, success}}, path, acc) do
    msg = "More as one schema matches (indexes: #{inspect(success)})"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{required: required}, path, acc) do
    msg = "Required properties are missing: #{inspect(required)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{property_names: errors, value: _value}, path, acc) do
    msg = ["Invalid property names#{at_path(path)}"]

    errors =
      errors
      |> Enum.map(fn {key, reason} ->
        "#{inspect(key)} : #{format_error(reason, [], [])}"
      end)
      |> Enum.reverse()
      |> indent()

    Enum.concat([errors, msg, acc])
  end

  defp format_error(%{dependencies: deps}, path, acc) do
    msg =
      deps
      |> Enum.reduce([], fn
        {key, reason}, acc when is_map(reason) ->
          sub_msg =
            reason
            |> format_error(path, [])
            |> Enum.reverse()
            |> indent()
            |> Enum.join("\n")

          ["Dependencies for #{inspect(key)} failed#{at_path(path)}\n#{sub_msg}" | acc]

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

  defp format_error(%{min_items: min, value: value}, path, acc) do
    msg = "Expected at least #{inspect(min)} items, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{max_items: max, value: value}, path, acc) do
    msg = "Expected at most #{inspect(max)} items, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{unique_items: true, value: value}, path, acc) do
    msg = "Expected unique items, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{const: const, value: value}, path, acc) do
    msg = "Expected #{inspect(const)}, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{pattern: pattern, value: value}, path, acc) do
    msg = "Pattern #{inspect(pattern)} does not match value #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{module: module, value: value}, path, acc) do
    msg = "Expected #{inspect(module)}, got #{inspect(value)}"
    [msg <> at_path(path) | acc]
  end

  defp format_error(%{validator: validator, value: value}, path, acc) do
    msg = "Validator fails with #{inspect(validator)} for value #{inspect(value)}"
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

  defp indent(list) when is_list(list), do: Enum.map(list, fn str -> "  #{str}" end)

  defp indent(str) do
    blanks = "  "
    blanks <> String.replace(str, ~r/\n/, "\n#{blanks}", global: true)
  end
end
