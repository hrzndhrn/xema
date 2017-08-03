defmodule Xema.Boolean do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct [as: :boolean]

  @type keywords :: %Xema.Boolean{
    as: atom
  }

  @spec new(keyword) :: Xema.Boolean.keywords
  def new(keywords), do: struct(Xema.Boolean, keywords)

  @spec is_valid?(Xema.t, any) :: boolean
  def is_valid?(_, true), do: true
  def is_valid?(_, false), do: true
  def is_valid?(_, _), do: false

  @spec validate(Xema.t, any) :: :ok | {:error, any}
  def validate(_, true), do: :ok
  def validate(_, false), do: :ok
  def validate(_, _), do: {:error, %{type: :boolean}}
end
