defmodule Amex.UnixTimestamp do
  @behaviour Xema.Caster

  @impl true
  def cast(timestamp) when is_integer(timestamp), do: {:ok, DateTime.from_unix!(timestamp)}

  def cast(%DateTime{} = timestamp), do: timestamp

  def cast(_), do: :error
end
