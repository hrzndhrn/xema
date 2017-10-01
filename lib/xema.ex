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
  end

  # new ----
  def xema(type, opts) do
    create_schema(type, opts(type, opts))
  end
  def xema(type) do
    create_schema(type, [])
  end

  def type(type, opts) do
    create_type(type, opts(type, opts))
  end
  def type({type, opts}) do
    create_type(type, opts(type, opts))
  end
  def type(type), do: create_type(type, [])


  # --------

  def opts(:list, opts) do
    Keyword.update(opts, :items, nil,
      fn
        items when is_atom(items) -> type(items)
        items when is_tuple(items) -> type(items)
        items when is_list(items) -> Enum.map(items, &type/1)
        items -> items
      end
    )
  end
  def opts(:map, opts) do
    opts
    |> Keyword.update(:properties, nil, &properties/1)
    |> Keyword.update(:pattern_properties, nil, &properties/1)
    |> Keyword.update(:dependencies, nil, &dependencies/1)
  end
  def opts(_, opts), do: opts
  # --------

  defp properties(map) do
    Enum.into(map, %{}, fn {key, prop} -> {key, type(prop)} end)
  end

  defp dependencies(map) do
    Enum.into(map, %{}, fn
      {key, dep} when is_list(dep) -> {key, dep}
      {key, dep} -> {key, type(dep)}
    end)
  end


  # ====================================

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(xema, value), do: validate(xema, value) == :ok

  @spec validate(Xema.t, any) :: :ok | {:error, any}
  def validate(xema, value), do: Validator.validate(xema, value)

end
