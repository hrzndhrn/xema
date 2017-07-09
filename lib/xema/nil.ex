defmodule Xema.Nil do
  @moduledoc """
  TODO
  """

  import Xema.Error

  @behaviour Xema

  defstruct as: :nil

  @spec keywords(list) :: %Xema{}
  def keywords(keywords), do: struct(%Xema.Nil{}, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(_keywords, nil), do: true
  def is_valid?(_keywords, _), do: false

  @spec validate(%Xema{}, any) :: :ok | {:error, map}
  def validate(_keywords, nil), do: :ok
  def validate(keywords, _value), do: error(:wrong_type, type: keywords.as)
end
