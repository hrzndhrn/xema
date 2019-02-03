defmodule Xema.Builder do
  @moduledoc """
  Experimental.
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
    def unquote(fun)(keywords \\ []) when is_list(keywords) do
      {unquote(fun), keywords}
    end
  end)

  def ref(ref) when is_binary(ref), do: {:ref, ref}
end
