defmodule Xema.Any do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct enum: nil

  alias Xema.Any

  use Xema.Enum

  @spec properties(list) :: nil
  def properties(properties), do: struct(%Any{}, properties)

  @spec is_valid?(%Any{}, any) :: boolean
  def is_valid?(properties, value), do: validate(properties, value) == :ok

  @spec validate(%Any{}, any) :: :ok | {:error, any}
  def validate(properties, value) do
    with :ok <- enum?(properties, value),
      do: :ok
  end
end
