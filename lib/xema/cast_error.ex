defmodule Xema.CastError do
  @moduledoc """
  Raised when a cast fails.
  """

  alias Xema.CastError

  defexception [:message, :reason]

  @message "Validation failed!"

  @impl true
  def exception(reason),
    do: %CastError{message: @message, reason: reason}
end
