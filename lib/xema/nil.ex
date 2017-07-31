defmodule Xema.Nil do
  @moduledoc """
  TODO
  """

  import Xema.Helper.Error

  @behaviour Xema

  defstruct as: :nil

  @spec new(list) :: %Xema.Nil{}
  def new(keywords), do: struct(%Xema.Nil{}, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(_xema, nil), do: true
  def is_valid?(_xema, _), do: false

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
  def validate(_xema, nil), do: :ok
  def validate(%Xema{keywords: keywords}, _value),
    do: error(:wrong_type, type: keywords.as)
end
