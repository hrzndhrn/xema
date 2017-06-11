defmodule Xema.Any do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  def properties(_), do: nil

  def is_valid?(_, _), do: true

  def validate(_, _), do: :ok
end
