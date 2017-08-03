defmodule Xema.Any do
  @moduledoc """
  TODO
  """

  import Xema.Validator.Enum

  @behaviour Xema

  defstruct [:enum, as: :any]

  @type keywords :: %Xema.Any{
    enum: list,
    as: atom
  }

  @spec new(keyword) :: Xema.Any.keywords
  def new(keywords), do: struct(Xema.Any, keywords)

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(schema, value), do: validate(schema, value) == :ok

  @spec validate(Xema.t, any) :: :ok | {:error, any}
  def validate(%Xema{keywords: keywords}, value) do
    with :ok <- enum(keywords, value),
      do: :ok
  end
end
