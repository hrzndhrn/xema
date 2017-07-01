defmodule Xema.Any do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct enum: nil

  alias Xema.Any

  use Xema.Enum

  @spec keywords(list) :: nil
  def keywords(keywords), do: struct(%Any{}, keywords)

  @spec is_valid?(%Any{}, any) :: boolean
  def is_valid?(keywords, value), do: validate(keywords, value) == :ok

  @spec validate(%Any{}, any) :: :ok | {:error, any}
  def validate(keywords, value) do
    with :ok <- enum(keywords, value),
      do: :ok
  end
end
