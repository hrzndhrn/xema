defmodule Xema.Any do
  @behaviour Xema

  def properties(_), do: nil

  def is_valid?(_, _), do: true
end

