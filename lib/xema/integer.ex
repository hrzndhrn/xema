defmodule Xema.Integer do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  @spec properties(list) :: nil
  def properties(_), do: nil

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(_, _), do: true

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(_, _), do: :ok
end
