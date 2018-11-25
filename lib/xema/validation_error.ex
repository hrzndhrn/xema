defmodule Xema.ValidationError do
  @moduledoc """
  Raised when a validation fails.
  """

  alias Xema.ValidationError

  defexception [:message, :reason]

  @message "Validation failed!"

  @impl true
  def exception(reason),
    do: %ValidationError{message: @message, reason: reason}
end
