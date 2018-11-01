defmodule Xema.RefError do
  alias Xema.RefError

  defexception [:message, :reason]

  @impl true
  def exception({:not_found, pointer} = reason) do
    message = "Reference '#{pointer}' not found."

    %RefError{message: message, reason: reason}
  end
end
