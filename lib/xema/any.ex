defmodule Xema.Any do
  @moduledoc """
  TODO
  """

  use Xema.Enum

  @behaviour Xema

  defstruct enum: nil

  @spec keywords(keyword) :: %Xema{}
  def keywords(keywords), do: struct(%Xema.Any{}, keywords)

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(keywords, value), do: validate(keywords, value) == :ok

  @spec validate(%Xema{}, any) :: :ok | {:error, any}
  def validate(keywords, value) do
    with :ok <- enum(keywords, value),
      do: :ok
  end
end
