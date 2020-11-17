defmodule Xema.Builder do
  @moduledoc """
  This module contains some convenience functions to generate schemas. Beside
  the type-functions the module contains the combinator-functions `all_of/2`,
  `any_of/2` and `one_of/2`.

  ## Examples

      iex> import Xema.Builder
      ...> schema = Xema.new integer(minimum: 1)
      ...> Xema.valid?(schema, 6)
      true
      ...> Xema.valid?(schema, 0)
      false
  """

  alias Xema.{CastError, Schema, ValidationError}

  @types Xema.Schema.types()

  @types
  |> Enum.filter(fn x -> x not in [nil, true, false, :struct] end)
  |> Enum.each(fn fun ->
    @doc """
    Returns :#{fun}.
    """
    @spec unquote(fun)() :: unquote(fun)
    def unquote(fun)() do
      unquote(fun)
    end

    @doc """
    Returns a tuple of `:#{fun}` and the given keyword list.

    ## Examples

        iex> Xema.Builder.#{fun}(key: 42)
        {:#{fun}, key: 42}
    """
    @spec unquote(fun)(keyword) :: {unquote(fun), keyword}
    def unquote(fun)(keywords) when is_list(keywords) do
      {unquote(fun), keywords}
    end
  end)

  @doc """
  Returns a tuple with the given `type` (default `:any`) and the given schemas
  tagged by the keyword `:any_of`. This function provides a shortcut for
  something like `integer(any_of: [...])` or `any(any_of: [...])`.

  ## Examples

      iex> Xema.Builder.any_of([:integer, :string])
      {:any, any_of: [:integer, :string] }

      iex> Xema.Builder.any_of(:integer, [[minimum: 10], [maximum: 5]])
      {:integer, any_of: [[minimum: 10], [maximum: 5]]}

  ```elixir
  defmodule MySchema do
    use Xema

    xema do
      any_of [
        list(items: integer(minimum: 1, maximum: 66)),
        list(items: integer(minimum: 33, maximum: 100))
      ]
    end
  end

  MySchema.valid?([20, 30]) #=> true
  MySchema.valid?([40, 50]) #=> true
  MySchema.valid?([60, 70]) #=> true
  MySchema.valid?([10, 90]) #=> false
  ```
  """
  @spec any_of(type, [schema]) :: {type, any_of: [schema]}
        when type: Schema.type(), schema: Schema.t() | Schema.type() | tuple | atom | keyword
  def any_of(type \\ :any, schemas) when type in @types and is_list(schemas) do
    {type, any_of: schemas}
  end

  @doc """
  Returns a tuple with the given `type` (default `:any`) and the given schemas
  tagged by the keyword `:all_of`. This function provides a shortcut for
  something like `integer(all_of: [...])` or `any(all_of: [...])`.

  ## Examples

      iex> Xema.Builder.all_of([:integer, :string])
      {:any, all_of: [:integer, :string] }

      iex> Xema.Builder.all_of(:integer, [[minimum: 10], [maximum: 5]])
      {:integer, all_of: [[minimum: 10], [maximum: 5]]}

  ```elixir
  defmodule MySchema do
    use Xema

    xema do
      all_of [
        list(items: integer(minimum: 1, maximum: 66)),
        list(items: integer(minimum: 33, maximum: 100))
      ]
    end
  end

  MySchema.valid?([20, 30]) #=> false
  MySchema.valid?([40, 50]) #=> true
  MySchema.valid?([60, 70]) #=> false
  MySchema.valid?([10, 90]) #=> false
  ```
  """
  @spec all_of(type, [schema]) :: {type, all_of: [schema]}
        when type: Schema.type(), schema: Schema.t() | Schema.type() | tuple | atom | keyword
  def all_of(type \\ :any, schemas) when type in @types and is_list(schemas) do
    {type, all_of: schemas}
  end

  @doc """
  Returns a tuple with the given `type` (default `:any`) and the given schemas
  tagged by the keyword `:one_of`. This function provides a shortcut for
  something like `integer(one_of: [...])` or `any(one_of: [...])`.

  ## Examples

      iex> Xema.Builder.one_of([:integer, :string])
      {:any, one_of: [:integer, :string] }

      iex> Xema.Builder.one_of(:integer, [[minimum: 10], [maximum: 5]])
      {:integer, one_of: [[minimum: 10], [maximum: 5]]}

  ```elixir
  defmodule MySchema do
    use Xema

    xema do
      one_of [
        list(items: integer(minimum: 1, maximum: 66)),
        list(items: integer(minimum: 33, maximum: 100))
      ]
    end
  end

  MySchema.valid?([20, 30]) #=> true
  MySchema.valid?([40, 50]) #=> false
  MySchema.valid?([60, 70]) #=> true
  MySchema.valid?([10, 90]) #=> false
  ```
  """
  @spec one_of(type, [schema]) :: {type, one_of: [schema]}
        when type: Schema.type(), schema: Schema.t() | Schema.type() | tuple | atom | keyword
  def one_of(type \\ :any, schemas) when type in @types and is_list(schemas) do
    {type, one_of: schemas}
  end

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
  Returns a tuple of `:struct` and the given keyword list when the function gets
  a keyword list.

  Returns the tuple `{:struct, module: module}` when the function gets an atom.
  """
  @spec strux(keyword) :: {:struct, keyword}
  def strux(keywords) when is_list(keywords), do: {:struct, keywords}

  @spec strux(atom) :: {:struct, module: module}
  def strux(module) when is_atom(module), do: strux(module: module)

  def strux(module, keywords) when is_atom(module),
    do: keywords |> Keyword.put(:module, module) |> strux()

  @doc """
  Creates a `schema`.
  """
  defmacro xema(do: schema) do
    quote do
      xema :__xema_default__ do
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
      Module.register_attribute(__MODULE__, :xemas, accumulate: true)

      multi = Module.get_attribute(__MODULE__, :multi)

      default = Module.get_attribute(__MODULE__, :default)
      Module.put_attribute(__MODULE__, :default, false)

      if multi == nil do
        raise "Use `use Xema` to use the `xema/2` macro."
      end

      if !multi && length(@xemas) > 0 do
        raise "Use `use Xema, multi: true` to setup multiple schema in a module."
      end

      Module.put_attribute(
        __MODULE__,
        :xemas,
        {unquote(name), Xema.new(add_new_module(unquote(schema), __MODULE__))}
      )

      if multi do
        if length(@xemas) == 1 do
          unquote(xema_funs(:header))
        end

        if default do
          unquote(xema_funs(:default, name))
        end

        unquote(xema_funs(:by_name, name))
      else
        if unquote(name) == :__xema_default__ do
          unquote(xema_funs(:single, name))
        else
          unquote(xema_funs(:header))
          unquote(xema_funs(:default, name))
          unquote(xema_funs(:by_name, name))
        end
      end
    end
  end

  defp xema_funs(:header) do
    quote do
      @doc """
      Returns true if the specified `data` is valid against the schema
      defined under `name`, otherwise false.
      """
      @spec valid?(atom, term) :: boolean
      def valid?(name \\ :default, data)

      @doc """
      Validates the given `data` against the schema defined under `name`.

      Returns `:ok` for valid data, otherwise an `:error` tuple.
      """
      @spec validate(atom, term) :: :ok | {:error, ValidationError.t()}
      def validate(name \\ :default, data)

      @doc """
      Validates the given `data` against the schema defined under `name`.

      Returns `:ok` for valid data, otherwise a `Xema.ValidationError` is
      raised.
      """
      @spec validate!(atom, term) :: :ok
      def validate!(name \\ :default, data)

      @doc """
      Converts the given `data` according to the schema defined under `name`.

      Returns an `:ok` tuple with the converted data for valid `data`, otherwise
      an `:error` tuple is returned.
      """
      @spec cast(atom, term) ::
              {:ok, term} | {:error, ValidationError.t() | CastError.t()}
      def cast(name \\ :default, data)

      @doc """
      Converts the given `data` according to the schema defined under `name`.

      Returns converted data for valid `data`, otherwise a `Xema.CastError` or
      `Xema.ValidationError` is raised.
      """
      @spec cast!(atom, term) :: {:ok, term}
      def cast!(name \\ :default, data)

      @doc false
      def xema(name \\ :default)
    end
  end

  defp xema_funs(:by_name, name) do
    quote do
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

      @doc false
      def xema(unquote(name)),
        do: @xemas[unquote(name)]
    end
  end

  defp xema_funs(:default, name) do
    quote do
      def valid?(:default, data),
        do: Xema.valid?(@xemas[unquote(name)], data)

      def validate(:default, data),
        do: Xema.validate(@xemas[unquote(name)], data)

      def validate!(:default, data),
        do: Xema.validate!(@xemas[unquote(name)], data)

      def cast(:default, data),
        do: Xema.cast(@xemas[unquote(name)], data)

      def cast!(:default, data),
        do: Xema.cast!(@xemas[unquote(name)], data)

      @doc false
      def xema(:default),
        do: @xemas[unquote(name)]
    end
  end

  defp xema_funs(:single, name) do
    quote do
      @doc """
      Returns true if the given `data` valid against the defined schema,
      otherwise false.
      """
      @spec valid?(term) :: boolean
      def valid?(data),
        do: Xema.valid?(@xemas[unquote(name)], data)

      @doc """
      Validates the given `data` against the defined schema.

      Returns `:ok` for valid data, otherwise an `:error` tuple.
      """
      @spec validate(term) :: :ok | {:error, ValidationError.t()}
      def validate(data),
        do: Xema.validate(@xemas[unquote(name)], data)

      @doc """
      Validates the given `data` against the defined schema.

      Returns `:ok` for valid data, otherwise a `Xema.ValidationError` is
      raised.
      """
      @spec validate!(term) :: :ok
      def validate!(data),
        do: Xema.validate!(@xemas[unquote(name)], data)

      @doc """
      Converts the given `data` according to the defined schema.

      Returns an `:ok` tuple with the converted data for valid `data`, otherwise
      an `:error` tuple is returned.
      """
      @spec cast(term) :: {:ok, term} | {:error, ValidationError.t() | CastError.t()}
      def cast(data),
        do: Xema.cast(@xemas[unquote(name)], data)

      @doc """
      Converts the given `data` according to the defined schema.

      Returns converted data for valid `data`, otherwise a `Xeam.CastError` or
      `Xema.ValidationError` is raised.
      """
      @spec cast!(term) :: term
      def cast!(data),
        do: Xema.cast!(@xemas[unquote(name)], data)

      @doc false
      def xema,
        do: @xemas[unquote(name)]
    end
  end

  defp xema_struct({:__block__, _context, data}) do
    data =
      data
      |> Enum.group_by(fn
        {name, _, _} when name in [:required, :field] -> name
        _ -> :rest
      end)
      |> Map.put_new(:field, [])
      |> Map.put_new(:required, nil)
      |> Map.put_new(:rest, nil)

    quote do
      unquote(data.rest)

      defstruct unquote(Enum.map(data.field, &xema_field_name/1))

      {:struct,
       [
         properties: Map.new(unquote(Enum.map(data.field, &xema_field/1))),
         keys: :atoms
       ]
       |> Keyword.merge(unquote(xema_required(data.required)))}
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

  @doc """
  Specifies a field. This function will be used inside `xema/0`.

  Arguments:

  + `name`: the name of the field.
  + `type`: the type of the field. The `type` can also be a `struct` or another
     schema.
  + `opts`: the rules for the field.

  ## Examples

      iex> defmodule User do
      ...>   use Xema
      ...>
      ...>   xema do
      ...>     field :name, :string, min_length: 1
      ...>   end
      ...> end
      ...>
      iex> %{"name" => "Tim"} |> User.cast!() |> Map.from_struct()
      %{name: "Tim"}

  For more examples see "[Examples: Struct](examples.html#struct)".
  """
  @spec field(atom, Schema.type() | module, keyword) ::
          {:xema, Xema.t()} | {:module, module} | {:type, atom}
  def field(name, type, opts \\ [])

  def field(name, type, opts) do
    case check_field_type!(name, type) do
      {:xema, module} -> module.xema()
      {:module, module} -> {:struct, Keyword.put(opts, :module, module)}
      {:type, type} -> {type, opts}
    end
  end

  defp check_field_type!(field, types) when is_list(types) do
    Enum.each(types, fn type -> check_field_type!(field, type) end)
    {:type, types}
  end

  defp check_field_type!(_field, type) when type in @types, do: {:type, type}

  defp check_field_type!(_field, module) when is_atom(module) do
    case Xema.behaviour?(module) do
      true -> {:xema, module}
      false -> {:module, module}
    end
  end

  defp check_field_type!(field, type),
    do: raise(ArgumentError, "invalid type #{inspect(type)} for field #{inspect(field)}")

  defp xema_required([required]) do
    quote do
      unquote(required)
    end
  end

  defp xema_required(nil) do
    quote do: []
  end

  defp xema_required(_) do
    raise ArgumentError, "the required function can only be called once per xema"
  end

  @doc """
  Sets the list of required fields.  Specifies a field. This function will be
  used inside `xema/0`.

  ## Examples

      iex> defmodule Person do
      ...>   use Xema
      ...>
      ...>   xema do
      ...>     field :name, :string, min_length: 1
      ...>     required [:name]
      ...>   end
      ...> end
      ...>
      iex> %{"name" => "Tim"} |> Person.cast!() |> Map.from_struct()
      %{name: "Tim"}
  """
  @spec required([atom]) :: term
  def required(fields), do: [required: fields]

  @doc false
  def add_new_module({:struct, keywords}, module),
    do: {:struct, Keyword.put_new(keywords, :module, module)}

  def add_new_module(schema, _module), do: schema
end
