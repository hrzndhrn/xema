defmodule Xema.Array do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct todo: :todo

  @spec properties(list) :: %Xema{}
  def properties(_), do: struct(%Xema.Array{}, [])

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(_, _), do: true

  @spec validate(%Xema{}, any) :: :ok | {:error, any}
  def validate(_, _), do: :ok
end
