defmodule Xema.Null do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  @spec properties(list) :: nil
  def properties(_), do: nil

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(_properties, nil), do: true
  def is_valid?(_properties, _), do: false

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(_properties, nil), do: :ok
  def validate(_properties, _value), do: {:error, %{type: :null}}
end
