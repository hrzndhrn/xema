defmodule Xema.Access do
  @moduledoc """
  Key- and index-based access to data structures with and without validation against a schema.
  """

  alias Xema.PathError

  @doc """
  TODO: doc `Xema.Access.get/2`
  """
  @spec get(Access.t(), nonempty_list(term)) :: term
  def get(data, [h]) when is_function(h), do: h.(:get, data, & &1)
  def get(data, [h | t]) when is_function(h), do: h.(:get, data, &get(&1, t))

  def get(nil, [_]), do: nil
  def get(nil, [_ | t]), do: get(nil, t)

  def get(data, [h]) when is_list(data) and is_integer(h), do: Enum.at(data, h)
  def get(data, [h | t]) when is_list(data) and is_integer(h), do: get(Enum.at(data, h), t)

  def get(data, [h]) when is_tuple(data) and is_integer(h),
    do: data |> Tuple.to_list() |> Enum.at(h)

  def get(data, [h | t]) when is_tuple(data) and is_integer(h),
    do: get(data |> Tuple.to_list() |> Enum.at(h), t)

  def get(data, [h]), do: Access.get(data, h)
  def get(data, [h | t]), do: get(Access.get(data, h), t)

  @doc """
  TODO: doc `Xema.Access.fetch/2
  """
  @spec fetch(Access.t(), nonempty_list(term)) :: {:ok, term} | {:error, term}
  def fetch(data, path) do
    with {:error, rest} <- do_fetch(data, path) do
      {:error,
       PathError.exception(
         path: Enum.take(path, length(path) - length(rest)),
         term: data
       )}
    end
  end

  @doc """
  TODO: doc `Xema.Access.fetch!/2
  """
  @spec fetch!(Access.t(), nonempty_list(term)) :: term
  def fetch!(data, path) do
    with {:ok, value} <- fetch(data, path) do
      value
    else
      {:error, error} -> raise(error)
    end
  end

  defp do_fetch(:error, path), do: {:error, path}

  defp do_fetch(data, []), do: {:ok, data}

  defp do_fetch(data, [h | t]) when is_function(h), do: h.(:get, data, &do_fetch(&1, t))

  defp do_fetch(nil, [_ | t]), do: do_fetch(nil, t)

  defp do_fetch(data, [h | t]) when is_list(data) and is_integer(h),
    do: do_fetch(Enum.at(data, h, :error), t)

  defp do_fetch(data, [h | t]) when is_tuple(data) and is_integer(h),
    do: do_fetch(data |> Tuple.to_list() |> Enum.at(h, :error), t)

  defp do_fetch(data, [h | t]), do: do_fetch(Access.get(data, h, :error), t)
end
