defmodule Xema.Builder do
  @moduledoc """
  TODO moduledoc
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

        iex> Xema.Build.#{fun}(key: 42)
        iex> {:#{fun}, [key: 42]}
    """
    @spec unquote(fun)(keyword) :: {unquote(fun), keyword}
    def unquote(fun)(keywords \\ []) when is_list(keywords) do
      {unquote(fun), keywords}
    end
  end)

  @doc """
  TODO ref
  """
  def ref(ref) when is_binary(ref), do: {:ref, ref}

  @doc """
  TODO defxema
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
