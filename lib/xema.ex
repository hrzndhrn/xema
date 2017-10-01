defmodule Xema do
  @moduledoc """
  Xema is a schema validator inspired by JSON Schema.

  Xema allows you to annotate and validate elixir data structures.

  Xema is in beta. If you try it and has an issue, report them.
  """

  alias Xema.Validator

  defstruct [
    :id,
    :schema,
    :title,
    :description,
    :type,
    :keywords
  ]

  @typedoc """
  The Xema base struct contains the meta data of a schema sub schema.

  * `id` a unique idenfifier.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `description` of the schema.
  * `type` contains the specification of the schema.
  """
  @type t :: %Xema{
    id: String.t,
    schema: String.t,
    title: String.t,
    description: String.t,
    type: type,
    keywords: any
  }

  @typedoc """
  The available type notations.
  """
  @type type ::
    :nil |
    :any |
    :boolean |
    :map |
    :list |
    :string |
    :number |
    :float |
    :integer

  @typedoc """
  The `keywords` for the schema types.
  """
  @type types ::
    Xema.Any.keywords |
    Xema.Nil.t |
    Xema.Boolean.keywords |
    Xema.Map.keywords |
    Xema.List.keywords |
    Xema.Number.keywords |
    Xema.String.keywords

  @types %{
    any: Xema.Any,
    nil: Xema.Nil,
    boolean: Xema.Boolean,
    map: Xema.Map,
    list: Xema.List,
    string: Xema.String,
    number: Xema.Number,
    float: Xema.Float,
    integer: Xema.Integer
  }

  @callback new(keyword) :: Xema.types

  @doc """
  This function defines the schemas.

  The first argument sets the `type` of the schema. The second arguments
  contains the keywords of the schema.

  ## Parameters

    - type: type of the schema.
    - opts: keywords of the schema.

  ## Examples

      iex> import Xema
      Xema
      iex> xema :string, min_length: 3, max_length: 12
      %Xema{
        type: :string,
        keywords: %Xema.String.Keywords{
          max_length: 12,
          min_length: 3,
        }
      }

  For nested schema you can use `{:type, opts: ...}` like here.

  ## Examples
      iex> import Xema
      Xema
      iex> schema = xema :list, items: {:number, minimum: 2}
      %Xema{
        type: :list,
        keywords: %Xema.List{
          items: %Xema{
            type: :number,
            keywords: %Xema.Number{
              minimum: 2
            }
          }
        }
      }
      iex> validate(schema, [2, 3, 4])
      :ok

  """

  @spec xema(type, keyword) :: Xema.t
  #def xema(type, data \\ [])

  @spec create_type(type, keyword) :: Xema.types
  # def create_type(type, opts \\ [])

  defp create_schema(type, opts \\ [])

  for {type, module} <- Map.to_list(@types) do

    defp create_schema(unquote(type), opts) do
      opts = Keyword.put(opts, :type, unquote(module).new(opts))
      struct(Xema, opts)
    end

    def create_type({unquote(type), opts}) do
      unquote(module).new(opts)
    end

    def create_type(unquote(type), opts) do
      unquote(module).new(opts)
    end


    #def xema(unquote(type), opts), do: do_xema(unquote(type), opts)

    #defp do_xema(unquote(type)), do: create_schema(unquote(type))
    #defp do_xema({unquote(type), data}), do: create_schema(unquote(type), do_xema(data))
    #defp do_xema(unquote(type), data), do: create_schema(unquote(type), do_xema(data))
  end

  # new ----
  def xema({type, opts}) when is_list(opts) do
    create_schema(type, Enum.map(opts, &map_values/1))
  end
  def xema({type, opts}) when is_map(opts) do
    create_schema(type, Enum.into(opts, %{}, &map_values/1))
  end
  def xema({type, opts}), do: create_schema(type, opts)

  def xema(type), do: create_schema(type, [])

  def xema(type, opts) when is_list(opts) do
    IO.puts "is list opts: #{inspect opts}"
    create_schema(type, Enum.map(opts, &map_values/1))
  end
  def xema(type, opts) when is_map(opts) do
    create_schema(type, Enum.into(opts, %{}, &map_values/1))
  end
  def xema(type, opts), do: create_schema(type, opts)

  # --------

  def type({type, opts}) when is_list(opts) do
    IO.puts "create #{inspect type}, #{inspect opts}"
    create_type(type, Enum.map(opts, &map_values/1))
  end
  def type({type, opts}) when is_map(opts) do
    create_type(type, Enum.into(opts, %{}, &map_values/1))
  end
  def type({type, opts}), do: create_type(type, opts)

  def type(type), do: create_type(type, [])

  def type(type, opts) when is_list(opts) do
    IO.puts "is list"
    create_type(type, Enum.map(opts, &map_values/1))
  end
  def type(type, opts) when is_map(opts) do
    create_type(type, Enum.into(opts, %{}, &map_values/1))
  end
  def type(type, opts), do: create_type(type, opts)
  # --------

  defp do_xema(data) when is_list(data), do: Enum.map(data, &map_values/1)
  defp do_xema(data) when is_map(data), do: Enum.into(data, %{}, &map_values/1)
  defp do_xema(data), do: data

  defp map_values({_keyword, %Xema{}} = data), do: data
  defp map_values({keyword, _value} = data)
    when keyword in [:required, :enum, :keys, :pattern],
    do: data
  defp map_values({:properties, props}) do
    IO.puts "properties"
    {:properties, Enum.map(props, fn {key, value} -> {key, type(value)} end)}
  end
  defp map_values({:items, items}) when is_list(items) do
    IO.puts "items"
    {:items, Enum.map(items, &type/1)}
  end
  defp map_values({:items, items}) when is_atom(items) do
    {:items, type(items)}
  end
  defp map_values({:dependencies, data}) do
    {
      :dependencies,
      Enum.into(data, %{}, fn {key, value} ->
        if is_list(value), do: {key, value}, else: {key, do_xema(value)}
      end)
    }
  end
  # defp map_values(data), do: do_map_values(data)
  defp map_values(data), do: data

  defp do_map_values({key, value}), do: {key, type(value)}

  # ====================================

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(xema, value), do: validate(xema, value) == :ok

  @spec validate(Xema.t, any) :: :ok | {:error, any}
  def validate(xema, value), do: Validator.validate(xema, value)

end
