defmodule Xema.Null do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  @spec keywords(list) :: nil
  def keywords(_), do: nil

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(_keywords, nil), do: true
  def is_valid?(_keywords, _), do: false

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(_keywords, nil), do: :ok
  def validate(_keywords, _value), do: {:error, %{type: :null}}
end
