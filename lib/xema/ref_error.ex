defmodule Xema.RefError do
  @moduledoc """
  Raised when a reference can't be handled.
  """

  alias Xema.RefError

  defexception [:message, :reason]

  @impl true
  def exception({:not_found, pointer} = reason) do
    message = "Reference '#{pointer}' not found."

    %RefError{message: message, reason: reason}
  end
end
