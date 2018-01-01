defmodule Xema do
  @moduledoc """
  A schema validator inspired by [JSON Schema](http://json-schema.org)
  """

  alias Xema.SchemaError
  alias Xema.Schema.Validator, as: SchemaValidator
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
          id: String.t() | nil,
          schema: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          type: types
        }

  @typedoc """
  The available type notations.
  """
  @type type ::
          nil
          | :any
          | :boolean
          | :map
          | :list
          | :string
          | :number
          | :float
          | :integer

  @typedoc """
  The `keywords` for the schema types.
  """
  @type types ::
          Xema.Any.t()
          | Xema.Nil.t()
          | Xema.Boolean.t()
          | Xema.Map.t()
          | Xema.List.t()
          | Xema.Number.t()
          | Xema.Integer.t()
          | Xema.Float.t()
          | Xema.String.t()

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

  @shortcuts [
    :all_of,
    :any_of,
    :enum,
    :minimum,
    :multiple_of,
    :not,
    :one_of
  ]

  @spec is_valid?(Xema.t(), any) :: boolean
  def is_valid?(xema, value), do: validate(xema, value) == :ok

  @spec validate(Xema.t() | Xema.types(), any) :: Validator.result()
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
        type: %Xema.Schema{
          max_length: 12,
          min_length: 3,
          type: :string,
          as: :string
        }
      }

  For nested schemas you can use `{:type, opts: ...}` like here.

  ## Examples
      iex> import Xema
      Xema
      iex> schema = xema :list, items: {:number, minimum: 2}
      %Xema{
        type: %Xema.Schema{
          type: :list,
          as: :list,
          items: %Xema.Schema{
            type: :number,
            as: :number,
            minimum: 2
          }
        }
      }
      iex> validate(schema, [2, 3, 4])
      :ok
      iex> validate(schema, [2, 3, 1])
      {:error, [%{
          at: 2,
          error: %{value: 1, minimum: 2}
      }]}

  """

  @spec xema(type, keyword) :: Xema.t()
  def xema(type, keywords \\ [])

  @doc false
  @spec type(type, keyword) :: types
  def type(type, keywords \\ [])

  for {type, module} <- @types do
    def xema(unquote(type), []) do
      new(Xema.Schema.new(type: unquote(type)))
    end

    def xema(unquote(type), opts) do
      case SchemaValidator.validate(unquote(type), opts) do
        :ok -> new(Xema.Schema.new(Keyword.put(opts, :type, unquote(type))), opts)
        {:error, msg} -> raise SchemaError, message: msg
      end
    end

    def type(unquote(type), []), do: Xema.Schema.new(type: unquote(type))

    def type({unquote(type), opts}, []) do
      case SchemaValidator.validate(unquote(type), opts) do
        :ok -> Xema.Schema.new(Keyword.put(opts, :type, unquote(type)))
        {:error, msg} -> raise SchemaError, message: msg
      end
    end
  end

  for keyword <- @shortcuts do
    def xema(unquote(keyword), opts), do: xema(:any, Keyword.new([{unquote(keyword), opts}]))

    def type({unquote(keyword), opts}, []),
      do: type({:any, Keyword.new([{unquote(keyword), opts}])})

    def type(%{unquote(keyword) => opts}, []),
      do: type({:any, Keyword.new([{unquote(keyword), opts}])})
  end

  def type(type, _) do
    raise SchemaError, message: "#{inspect(type)} is not a valid type."
  end

  defp new(type), do: struct(Xema, type: type)

  defp new(type, fields), do: struct(Xema, Keyword.put(fields, :type, type))
end
