defmodule Xema.Nil do
  @moduledoc """
  TODO
  """

  import Xema.Helper.Error

  @behaviour Xema

  defstruct as: :nil

  @type keywords :: %Xema.Nil{
    as: atom
  }

  @spec new(list) :: Xema.Nil.keywords
  def new(keywords), do: struct(Xema.Nil, keywords)

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(_xema, nil), do: true
  def is_valid?(_xema, _), do: false

  @spec validate(Xema.t, any) :: :ok | {:error, map}
  def validate(_xema, nil), do: :ok
  def validate(%Xema{keywords: keywords}, _value),
    do: error(:wrong_type, type: keywords.as)
end
