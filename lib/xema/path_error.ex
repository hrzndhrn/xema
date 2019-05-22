defmodule Xema.PathError do
  defexception [:path, :term, :message]

  @impl true
  def message(%{message: nil} = exception), do: message(exception.path, exception.term)
  def message(%{message: message}), do: message

  defp message(path, term), do: "path #{inspect(path)} not found in: #{inspect(term)}"

  @impl true
  def blame(exception, stacktrace) do
    IO.inspect("blame")
    message = message(exception.path, exception.term)
    {%{exception | message: message}, stacktrace}
  end
end
