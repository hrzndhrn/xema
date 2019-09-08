defmodule Amex do
  @moduledoc """
  An example for `Xema`.
  """

  alias Amex.Multi

  def num(schema \\ :default, value)

  def num(:default, value), do: Multi.valid?(value)

  def num(schema, value) when schema in [:pos, :neg], do: Multi.valid?(schema, value)
end
