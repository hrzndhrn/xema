defmodule Xema.Builder do
  @moduledoc """
  This module contains some convenience functions to generate schemas.

  ## Examples

      iex> import Xema.Builder
      ...> schema = Xema.new integer(minimum: 1)
      ...> Xema.valid?(schema, 6)
      true
      ...> Xema.valid?(schema, 0)
      false
  """

  @funs ~w(
    any
    atom
    boolean
    float
    integer
    keyword
    list
    map
    number
    string
    struct
    tuple
  )a

  Enum.each(@funs, fn fun ->
    @doc """
    Returns a tuple of `:#{fun}` and the given keyword list.

    ## Examples

        iex> Xema.Builder.#{fun}(key: 42)
        {:#{fun}, [key: 42]}
    """
    @spec unquote(fun)(keyword) :: {unquote(fun), keyword}
    def unquote(fun)(keywords \\ []) when is_list(keywords) do
      {unquote(fun), keywords}
    end
  end)

  @doc """
  Returns the tuple `{:ref, ref}`.
  """
  def ref(ref) when is_binary(ref), do: {:ref, ref}

  @doc """
  Create a function with the `name` that returns the given `schema`.
  """
  defmacro defxema(name, schema) do
    xema =
      quote do
        Xema.new(unquote(schema))
      end

    quote do
      def unquote(name), do: unquote(xema)
    end
  end
end
