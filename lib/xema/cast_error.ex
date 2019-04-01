defmodule Xema.CastError do
  @moduledoc """
  Raised when a cast fails.
  """

  alias Xema.CastError

  defexception [:message, :path, :to, :value, :key]

  @impl true
  def exception(%{path: path, to: to, value: value} = error) do
    %CastError{
      message: format_error(error),
      to: to,
      value: value,
      path: path
    }
  end

  def exception(%{path: path, to: to, key: key} = error) do
    %CastError{
      message: format_error(error),
      to: to,
      key: key,
      path: path
    }
  end

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

  def format_error(error) do
    "unexpected error: #{inspect(error)}"
  end
end
