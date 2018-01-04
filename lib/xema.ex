defmodule Xema do
  @moduledoc """
  A schema validator inspired by [JSON Schema](http://json-schema.org)
  """

  alias Xema.Schema
  alias Xema.Schema.Validator, as: SchemaValidator
  alias Xema.SchemaError
  alias Xema.Validator

  @enforce_keys [:content]

  defstruct [
    :content,
    :description,
    :id,
    :keywords,
    :schema,
    :title
  ]

  @typedoc """
  The Xema base struct contains the meta data of a schema.

  * `id` a unique identifier.
  * `schema` declares the used schema.
  * `title` of the schema.
  * `description` of the schema.
  * `type` contains the specification of the schema.
  """
  @type t :: %Xema{
          content: Xema.Schema.t(),
          description: String.t() | nil,
          id: String.t() | nil,
          schema: String.t() | nil,
          title: String.t() | nil
        }

  @typedoc """
  The available type notations.
  """
  @type schema_types ::
          :any
          | :boolean
          | :float
          | :integer
          | :list
          | :map
          | nil
          | :number
          | :string

  @schema_types [
    :any,
    :boolean,
    :float,
    :integer,
    :list,
    :map,
    nil,
    :number,
    :string
  ]

  @typedoc """
  The available schema keywords.
  """
  @type schema_keywords ::
          :additional_items
          | :additional_properties
          | :all_of
          | :any_of
          | :dependencies
          | :enum
          | :exclusive_maximum
          | :exclusive_minimum
          | :items
          | :keys
          | :max_items
          | :max_length
          | :max_properties
          | :maximum
          | :min_items
          | :min_length
          | :min_properties
          | :minimum
          | :multiple_of
          | :not
          | :one_of
          | :pattern
          | :pattern_properties
          | :properties
          | :required
          | :unique_items

  @schema_keywords [
    :additional_items,
    :additional_properties,
    :all_of,
    :any_of,
    :dependencies,
    :enum,
    :exclusive_maximum,
    :exclusive_minimum,
    :items,
    :keys,
    :max_items,
    :max_length,
    :max_properties,
    :maximum,
    :min_items,
    :min_length,
    :min_properties,
    :minimum,
    :multiple_of,
    :not,
    :one_of,
    :pattern,
    :pattern_properties,
    :properties,
    :required,
    :unique_items
  ]

  @spec is_valid?(Xema.t(), any) :: boolean
  def is_valid?(schema, value), do: validate(schema, value) == :ok

  @spec validate(Xema.t() | Xema.Schema.t(), any) :: Validator.result()
  def validate(schema, value), do: Validator.validate(schema, value)

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
        content: %Xema.Schema{
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
        content: %Xema.Schema{
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

  @spec xema(schema_types | tuple, keyword) :: Xema.t()
  def xema(type, keywords \\ [])

  def xema({type}, []), do: xema(type, [])

  def xema({type, keywords}, []), do: xema(type, keywords)

  def xema(tuple, keywords) when is_tuple(tuple),
    do: raise(ArgumentError, message: "Invalid argument #{inspect(keywords)}")

  @doc false
  @spec schema(schema_types, keyword) :: Xema.Schema.t()
  def schema(type, keywords \\ [])

  for type <- @schema_types do
    def xema(unquote(type), []), do: create(Schema.new(type: unquote(type)))

    def xema(unquote(type), opts) do
      schema_opts =
        opts
        |> Keyword.put(:type, unquote(type))
        |> Keyword.delete(:id)
        |> Keyword.delete(:title)
        |> Keyword.delete(:description)
        |> Keyword.delete(:schema)

      case SchemaValidator.validate(unquote(type), schema_opts) do
        :ok -> create(Schema.new(schema_opts), opts)
        {:error, msg} -> raise SchemaError, message: msg
      end
    end

    def schema(unquote(type), []), do: Schema.new(type: unquote(type))

    def schema({unquote(type), opts}, []) do
      case SchemaValidator.validate(unquote(type), opts) do
        :ok -> Schema.new(Keyword.put(opts, :type, unquote(type)))
        {:error, msg} -> raise SchemaError, message: msg
      end
    end
  end

  for keyword <- @schema_keywords do
    def xema(unquote(keyword), opts), do: xema(:any, Keyword.new([{unquote(keyword), opts}]))

    def schema({unquote(keyword), opts}, []),
      do: schema({:any, Keyword.new([{unquote(keyword), opts}])})

    def schema(%{unquote(keyword) => opts}, []),
      do: schema({:any, Keyword.new([{unquote(keyword), opts}])})
  end

  def schema(type, _) do
    raise SchemaError, message: "#{inspect(type)} is not a valid type or keyword."
  end

  defp create(schema), do: struct(Xema, content: schema)

  defp create(schema, fields), do: struct(Xema, Keyword.put(fields, :content, schema))

  @spec to_string(Xema.t(), keyword) :: String.t()
  def to_string(%Xema{} = xema, opts \\ []) do
    format = Keyword.get(opts, :format, :call)
    {schema, keywords} = to_tuple(xema)

    to_string(format, schema, keywords)
  end

  @spec to_string(atom, Schema.t, keyword) :: String.t
  defp to_string(:call = format, schema, keywords) do
    "xema(#{Schema.to_string(schema, root: true, keywords: keywords, format: format)})"
  end

  defp to_string(:data, schema, keywords) do
    Schema.to_string(schema, root: true, keywords: keywords)
  end

  @spec to_tuple(Xema.t) :: {Schema.t, keyword}
  defp to_tuple(xema) do
    {
      xema.content,
      xema
      |> Map.from_struct()
      |> Map.delete(:content)
      |> Enum.filter(fn {_key, value} -> value != nil end)
    }
  end
end

defimpl String.Chars, for: Xema do
  @spec to_string(Xema.t) :: String.t
  def to_string(xema), do: Xema.to_string(xema)
end
