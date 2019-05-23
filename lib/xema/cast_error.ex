defmodule Xema.CastError do
  @moduledoc """
  Raised when a cast fails.
  """

  defexception [:message, :path, :to, :value, :key]

  alias Xema.CastError

  @type t :: %CastError{}

  @type error :: %{
          to: atom,
          value: term,
          key: String.t(),
          path: [atom | integer | String.t()]
        }

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
  @spec format_error(error) :: String.t()
  def format_error(%{path: [], to: :atom, value: value}) when is_binary(value) do
    "cannot cast #{inspect(value)} to :atom, the atom is unknown"
  end

  def format_error(%{path: [], to: to, key: key}) when is_binary(key) do
    "cannot cast #{inspect(key)} to #{inspect(to)} key, the atom is unknown"
  end

  def format_error(%{path: path, to: to, key: key}) when is_binary(key) do
    "cannot cast #{inspect(key)} to #{inspect(to)} key at #{inspect(path)}, the atom is unknown"
  end

  def format_error(%{path: [], to: to, value: value}) do
    "cannot cast #{inspect(value)} to #{inspect(to)}"
  end

  def format_error(%{path: path, to: to, value: value}) do
    "cannot cast #{inspect(value)} to #{inspect(to)} at #{inspect(path)}"
  end
end
