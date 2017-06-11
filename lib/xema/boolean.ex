defmodule Xema.Boolean do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  @spec properties(list) :: nil
  def properties(_), do: nil

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(_, _), do: false

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(_, _), do: {:error, :not_implemented}
end
