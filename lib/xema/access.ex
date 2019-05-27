defmodule Xema.Access do
  @moduledoc """
  Key- and index-based access to data structures.
  """

  alias Xema.PathError

  @error :__an_access_error__

  @doc """
  Gets a value from a nested structure.

  Used by `Xema.get/2` and `Xema.get/3`.
  """
  @spec get(Access.t(), nonempty_list(term)) :: term
  def get(nil, [_]), do: nil

  def get(nil, [_ | tail]), do: get(nil, tail)

  def get(data, [head])
      when is_function(head),
      do: head.(:get, data, & &1)

  def get(data, [head | tail])
      when is_function(head),
      do: head.(:get, data, &get(&1, tail))

  def get(data, [head])
      when is_list(data) and is_integer(head),
      do: Enum.at(data, head)

  def get(data, [head | tail])
      when is_list(data) and is_integer(head),
      do: get(Enum.at(data, head), tail)

  def get(data, [head])
      when is_tuple(data) and is_integer(head),
      do: data |> Tuple.to_list() |> Enum.at(head)

  def get(data, [head | tail])
      when is_tuple(data) and is_integer(head),
      do: get(data |> Tuple.to_list() |> Enum.at(head), tail)

  def get(data, [head]), do: Access.get(data, head)

  def get(data, [head | tail]), do: get(Access.get(data, head), tail)

  @doc """
  Fetches a value from a nested structure.

  Used by `Xema.fetch/2` and `Xema.fetch/3`.
  """
  @spec fetch(Access.t(), nonempty_list(term)) :: {:ok, term} | {:error, term}
  def fetch(data, path) do
    with {@error, rest} <- do_fetch(data, path) do
      {:error,
       PathError.exception(
         path: Enum.take(path, length(path) - length(rest)),
         term: data
       )}
    end
  end

  @doc """
  Fetches a value from a nested structure.

  Used by `Xema.fetch!/2` and `Xema.fetch!/3`.
  """
  @spec fetch!(Access.t(), nonempty_list(term)) :: term
  def fetch!(data, path) do
    with {:ok, value} <- fetch(data, path) do
      value
    else
      {:error, error} -> raise(error)
    end
  end

  defp do_fetch(@error, path), do: {@error, path}

  defp do_fetch(data, []), do: {:ok, data}

  defp do_fetch(nil, [_ | tail]), do: do_fetch(@error, tail)

  defp do_fetch(data, [head | tail])
       when is_function(head),
       do: head.(:get, data, &do_fetch(&1, tail))

  defp do_fetch(data, [head | tail])
       when is_list(data) and is_integer(head),
       do: do_fetch(Enum.at(data, head, @error), tail)

  defp do_fetch(data, [head | tail])
       when is_tuple(data) and is_integer(head),
       do: do_fetch(data |> Tuple.to_list() |> Enum.at(head, @error), tail)

  defp do_fetch(data, [head | tail]), do: do_fetch(Access.get(data, head, @error), tail)
end
