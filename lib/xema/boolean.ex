defmodule Xema.Boolean do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  def properties(_), do: nil

  def is_valid?(_, _), do: false

  def validate(_, _), do: {:error, :not_implemented}
end
