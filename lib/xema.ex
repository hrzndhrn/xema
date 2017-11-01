defmodule Xema do
  @moduledoc File.read!("README.md")

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
  The Xema base struct contains the meta data of a schema.

  * `id` a unique idenfifier.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `description` of the schema.
  * `type` contains the specification of the schema.
  """
  @type t :: %Xema{
    id: String.t | nil,
    schema: String.t | nil,
    title: String.t | nil,
    description: String.t | nil,
    type: types
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
    Xema.Any.t |
    Xema.Nil.t |
    Xema.Boolean.t |
    Xema.Map.t |
    Xema.List.t |
    Xema.Number.t |
    Xema.Integer.t |
    Xema.Float.t |
    Xema.String.t

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

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(xema, value), do: validate(xema, value) == :ok

  @spec validate(Xema.t, any) :: :ok | {:error, any}
  def validate(xema, value), do: Validator.validate(xema, value)

  @doc """
  This function defines the schemas.

  The first argument sets the `type` of the schema. The second arguments
  contains the 'keywords' of the schema.

  ## Parameters

    - type: type of the schema.
    - opts: keywords of the schema.

  ## Examples

      iex> import Xema
      Xema
      iex> xema :string, min_length: 3, max_length: 12
      %Xema{
        type: %Xema.String{
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
        type: %Xema.List{
          items: %Xema.Number{
            minimum: 2
          }
        }
      }
      iex> validate(schema, [2, 3, 4])
      :ok
      iex> validate(schema, [2, 3, 1])
      {:error,
        %{
          reason: :invalid_item,
          at: 2,
          error: %{
            minimum: 2,
            reason: :too_small
          }
        }
      }

  """

  @spec xema(type, keyword) :: Xema.t
  def xema(type, keywords \\ [])
  for {type, module} <- @types do
    def xema(unquote(type), []) do
      struct(Xema, [type: struct(unquote(module), [])])
    end
    def xema(unquote(type), opts) do
      opts = opts(unquote(type), opts)
      struct(Xema, Keyword.put(opts, :type, struct(unquote(module), opts)))
    end

    defp type(unquote(type), opts) do
      # unquote(module).new(opts(unquote(type), opts))
      struct(unquote(module), opts(unquote(type), opts))
    end
    defp type({unquote(type), opts}) do
      # unquote(module).new(opts(unquote(type), opts))
      struct(unquote(module), opts(unquote(type), opts))
    end
    defp type(unquote(type)) do
      # unquote(module).new([])
      struct(unquote(module), [])
    end
  end

  defp opts(:list, opts) do
    Keyword.update(opts, :items, nil,
      fn
        items when is_atom(items) -> type(items)
        items when is_tuple(items) -> type(items)
        items when is_list(items) -> Enum.map(items, &type/1)
        items -> items
      end
    )
  end
  defp opts(:map, opts) do
    opts
    |> Keyword.update(:properties, nil, &properties/1)
    |> Keyword.update(:pattern_properties, nil, &properties/1)
    |> Keyword.update(:dependencies, nil, &dependencies/1)
    |> Keyword.update(:required, nil, &(MapSet.new(&1)))
  end
  defp opts(_, opts), do: opts

  defp properties(map) do
    Enum.into(map, %{}, fn {key, prop} -> {key, type(prop)} end)
  end

  defp dependencies(map) do
    Enum.into(map, %{}, fn
      {key, dep} when is_list(dep) -> {key, dep}
      {key, dep} -> {key, type(dep)}
    end)
  end
end
