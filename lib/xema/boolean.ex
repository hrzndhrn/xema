defmodule Xema.Boolean do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct []

  @spec new(keyword) :: %Xema{}
  def new(_), do: struct(%Xema.Boolean{})

  @spec is_valid?(%Xema{}, any) :: boolean
  def is_valid?(_, true), do: true
  def is_valid?(_, false), do: true
  def is_valid?(_, _), do: false

  @spec validate(%Xema{}, any) :: :ok | {:error, any}
  def validate(_, true), do: :ok
  def validate(_, false), do: :ok
  def validate(_, _), do: {:error, %{type: :boolean}}
end
