defmodule Xema.Float do
  @moduledoc """
  This module contains the keywords and validation functions for a `float`
  schema.

  Supported keywords:
  * `minimum` specifies a minimum numeric value.
  * `maximum` specifies a maximum numeric value.
  * `exclusive_minimum` is a boolean. When `true`, it indicates that the
    `minimum` excludes the value himself, i.e., x > min. When false (or not set)
    , it indicates that the `minimum` includes the value himself, i.e., x ≥ min.
  * `exclusive_maximum`
  * `multiple_of` restrict the value to a multiple of the given number.
  * `enum` specifies an enumeration.

  `as` can be an atom that will be report in an error case as type of the
  schema. Default of `as` is `:float`

  ## Examples

      iex> import Xema
      Xema
      iex> float = xema :float, minimum: 2.3, as: :frac
      %Xema{
        keywords: %Xema.Float{
          as: :frac,
          enum: nil,
          exclusive_maximum: nil,
          exclusive_minimum: nil,
          maximum: nil,
          minimum: 2.3,
          multiple_of: nil
        },
        type: :float,
        id: nil,
        schema: nil,
        title: nil,
        description: nil,
        default: nil
      }
      iex> validate(float, 3.2)
      :ok
      iex> validate(float, 1.1)
      {:error, %{minimum: 2.3, reason: :too_small}}
      iex> validate(float, "foo")
      {:error, %{reason: :wrong_type, type: :frac}}

  """

  import Xema.Helper.Error
  import Xema.Validator.Enum
  import Xema.Validator.Number

  @behaviour Xema

  defstruct [
    :minimum,
    :maximum,
    :exclusive_maximum,
    :exclusive_minimum,
    :multiple_of,
    :enum,
    as: :float
  ]

  @type keywords :: %Xema.Float{
    minimum: integer,
    maximum: integer,
    exclusive_minimum: boolean,
    exclusive_maximum: boolean,
    multiple_of: number,
    enum: list,
    as: atom
  }

  @spec new(keyword) :: Xema.Float.keywords
  def new(keywords), do: struct(Xema.Float, keywords)

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(xema, number), do: validate(xema, number) == :ok

  @spec validate(Xema.t, any) :: :ok | {:error, map}
  def validate(%Xema{keywords: keywords}, number) do
    with :ok <- type(keywords, number),
         :ok <- minimum(keywords, number),
         :ok <- maximum(keywords, number),
         :ok <- multiple_of(keywords, number),
         :ok <- enum(keywords, number),
      do: :ok
  end

  defp type(_keywords, number) when is_float(number), do: :ok
  defp type(keywords, _number), do: error(:wrong_type, type: keywords.as)
end
