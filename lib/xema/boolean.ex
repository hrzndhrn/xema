defmodule Xema.Boolean do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  @spec keywords(list) :: nil
  def keywords(_), do: nil

  @spec is_valid?(nil, any) :: boolean
  def is_valid?(_, true), do: true
  def is_valid?(_, false), do: true
  def is_valid?(_, _), do: false

  @spec validate(nil, any) :: :ok | {:error, any}
  def validate(_, true), do: :ok
  def validate(_, false), do: :ok
  def validate(_, _), do: {:error, %{type: :boolean}}
end
