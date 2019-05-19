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
    tuple
  )a

  Enum.each(@funs, fn fun ->
    @doc """
    Returns a tuple of `:#{fun}` and the given keyword list.

    ## Examples

        iex> Xema.Builder.#{fun}(key: 42)
        {:#{fun}, [key: 42]}
    """
    @spec unquote(fun)() :: unquote(fun)
    def unquote(fun)() do
      unquote(fun)
    end

    @spec unquote(fun)(keyword) :: {unquote(fun), keyword}
    def unquote(fun)(keywords) when is_list(keywords) do
      {unquote(fun), keywords}
    end
  end)

  @doc """
  Returns the tuple `{:ref, ref}`.
  """
  def ref(ref) when is_binary(ref), do: {:ref, ref}

  @doc """
  Returns `:struct`.
  """
  @spec strux :: :struct
  def strux, do: :struct

  @doc """
  Returns a tuple of `:stuct` and the given keyword list.
  """
  @spec strux(keyword) :: {:struct, keyword}
  def strux(keywords) when is_list(keywords), do: {:struct, keywords}

  @doc """
  Returns the tuple `{:struct, module: module}`.
  """
  @spec strux(atom) :: {:struct, module: module}
  def strux(module) when is_atom(module), do: strux(module: module)

  def strux(module, keywords) when is_atom(module),
    do: keywords |> Keyword.put(:module, module) |> strux()

  @doc """
  Create a function with the `name` that returns the given `schema`.
  """
  defmacro xema(name, schema) do
    quote do

      if Module.get_attribute(__MODULE__, :multi) == nil do
        raise "Use `use Xema` to to use the `xema/2` macro."
      end

      Module.register_attribute(__MODULE__, :xemas, accumulate: true)


      if !@multi && length(@xemas) > 0 do
        raise "Use `use Xema, multi: true` to setup multiple schema in a module."
      end

      Module.put_attribute(
        __MODULE__,
        :xemas,
        {unquote(name), Xema.new(unquote(schema))}
      )

      def valid?(unquote(name), data),
        do: Xema.valid?(@xemas[unquote(name)], data)

      def validate(unquote(name), data),
        do: Xema.validate(@xemas[unquote(name)], data)

      def validate!(unquote(name), data),
        do: Xema.validate!(@xemas[unquote(name)], data)

      if Module.get_attribute(__MODULE__, :default) || !@multi do
        Module.put_attribute(__MODULE__, :default, false)

        def valid?(data),
          do: Xema.valid?(@xemas[unquote(name)], data)

        def validate(data),
          do: Xema.validate(@xemas[unquote(name)], data)

        def validate!(data),
          do: Xema.validate!(@xemas[unquote(name)], data)
      end
    end
  end
end
