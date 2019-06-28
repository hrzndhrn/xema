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

  @types Xema.Schema.types()

  @types
  |> Enum.filter(fn x -> x not in [nil, true, false, :struct] end)
  |> Enum.each(fn fun ->
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
  Creates a `schema`.
  """
  defmacro xema(do: schema) do
    quote do
      xema :default do
        unquote(schema)
      end
    end
  end

  @doc """
  Creates a `schema` with the given name.
  """
  defmacro xema(name, do: schema) do
    schema = xema_struct(schema)

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
        {unquote(name), Xema.new(add_new_module(unquote(schema), __MODULE__))}
      )

      def valid?(unquote(name), data),
        do: Xema.valid?(@xemas[unquote(name)], data)

      def validate(unquote(name), data),
        do: Xema.validate(@xemas[unquote(name)], data)

      def validate!(unquote(name), data),
        do: Xema.validate!(@xemas[unquote(name)], data)

      def cast(unquote(name), data),
        do: Xema.cast(@xemas[unquote(name)], data)

      def cast!(unquote(name), data),
        do: Xema.cast!(@xemas[unquote(name)], data)

      def xema(unquote(name)),
        do: @xemas[unquote(name)]

      if Module.get_attribute(__MODULE__, :default) || !@multi do
        Module.put_attribute(__MODULE__, :default, false)

        def valid?(data),
          do: Xema.valid?(@xemas[unquote(name)], data)

        def validate(data),
          do: Xema.validate(@xemas[unquote(name)], data)

        def validate!(data),
          do: Xema.validate!(@xemas[unquote(name)], data)

        def cast(data),
          do: Xema.cast(@xemas[unquote(name)], data)

        def cast!(data),
          do: Xema.cast!(@xemas[unquote(name)], data)

        def xema(),
          do: @xemas[unquote(name)]
      end
    end
  end

  defp xema_struct({:__block__, _context, data}) do
    data =
      Enum.group_by(data, fn
        {name, _, _} when name == :field -> name
        _ -> :rest
      end)
      |> Map.put_new(:field, [])
      |> Map.put_new(:rest, nil)

    quote do
      unquote(data.rest)

      defstruct unquote(Enum.map(data.field, &xema_field_name/1))

      {:struct,
       [
         properties: Map.new(unquote(Enum.map(data.field, &xema_field/1))),
         keys: :atoms
       ]
      }
    end
  end

  defp xema_struct({:field, _context, _args} = data) do
    quote do
      defstruct [unquote(xema_field_name(data))]

      {:struct,
       [
         properties: Map.new([unquote(xema_field(data))]),
         keys: :atoms
       ]}
    end
  end

  defp xema_struct(data), do: data

  defp xema_field({:field, _context, [name | _]} = field) do
    quote do
      {unquote(name), unquote(field)}
    end
  end

  defp xema_field_name({:field, _context, [name | _]}) do
    quote do
      unquote(name)
    end
  end

  def field(_name, type, keywords), do: {type, keywords}

  def field(_name, type), do: type

  @doc false
  def add_new_module({:struct, keywords}, module),
    do: {:struct, Keyword.put_new(keywords, :module, module)}

  def add_new_module(schema, _module), do: schema
end
