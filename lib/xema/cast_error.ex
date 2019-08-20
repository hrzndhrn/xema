defmodule Xema.CastError do
  @moduledoc """
  Raised when a cast fails.
  """

  alias Xema.CastError

  defexception [:message, :path, :required, :to, :value, :key, :error]

  # TODO
  @type t :: %CastError{
          error: struct | nil,
          key: String.t() | atom | nil,
          message: String.t() | nil,
          path: [atom | integer | String.t()] | nil,
          required: [atom] | nil,
          to: atom | nil,
          value: term | nil
        }

  @indent "  "

  @impl true
  def message(%{message: nil} = exception), do: format_error(exception)

  def message(%{message: message}), do: message

  @impl true
  def blame(exception, stacktrace) do
    message = message(exception)
    {%{exception | message: message}, stacktrace}
  end

  @doc """
  Formats the error map to an error message.
  """
  @spec format_error(CastError.t()) :: String.t()
  def format_error(error) do
    error
    |> traverse_error()
    |> List.flatten()
    |> Enum.join("\n")
  end

  defp traverse_error(%{path: path, to: to, error: error, value: value}) when not is_nil(error) do
    ["cannot cast #{inspect(value)} to #{inspect(to)}, " <> error.message <> at_path(path)]
  end

  defp traverse_error(%{path: path, to: :atom, value: value}) when is_binary(value) do
    ["cannot cast #{inspect(value)} to :atom, the atom is unknown" <> at_path(path)]
  end

  defp traverse_error(%{path: path, to: to, key: {:ambiguous, key}}) do
    [
      "cannot cast #{to_string(key)} to #{inspect(to)} key" <>
        at_path(path) <> ", the key is ambiguous"
    ]
  end

  defp traverse_error(%{path: path, to: to, key: key}) when is_binary(key) do
    [
      "cannot cast #{inspect(key)} to #{inspect(to)} key" <>
        at_path(path) <> ", the atom is unknown"
    ]
  end

  defp traverse_error(%{path: path, to: to, key: key, value: value}) when not is_nil(key) do
    [
      "cannot cast #{inspect(value)} to #{inspect(to)}, " <>
        "key #{inspect(key)} not found in #{inspect(to)}" <> at_path(path)
    ]
  end

  defp traverse_error(%{path: path, to: to, value: value}) when is_list(to) do
    if Enum.all?(to, &is_atom/1) do
      ["cannot cast #{inspect(value)} to any of #{inspect(to)}" <> at_path(path)]
    else
      errors = to |> Enum.map(fn error -> traverse_error(error) end) |> indent()
      ["cannot cast #{inspect(value)}" <> at_path(path) <> " to any of:" | errors]
    end
  end

  defp traverse_error(%{path: path, to: to, value: value, required: required})
       when not is_nil(required) do
    [
      "cannot cast #{inspect(value)} to #{inspect(to)}" <>
        "#{at_path(path)} missing required keys #{inspect(required)}"
    ]
  end

  defp traverse_error(%{path: path, to: to, value: value}) do
    ["cannot cast #{inspect(value)} to #{inspect(to)}" <> at_path(path)]
  end

  defp at_path([]), do: ""

  defp at_path(path), do: " at #{inspect(path)}"

  defp indent(list) when is_list(list), do: Enum.map(list, &indent/1)

  defp indent(str), do: @indent <> str
end
