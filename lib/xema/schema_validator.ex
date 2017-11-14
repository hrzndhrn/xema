defmodule Xema.SchemaValidator do
  @moduledoc false

  def validate(opts) do
    with :ok <- minimum opts do
      opts
    else
      error -> throw error
    end
  end

  defp minimum([minimum: value]) when is_integer(value), do: :ok

  defp minimum([minimum: value]) do
    {:error, "Expected an integer for minimum, got #{inspect value}"}
  end

  defp minimum(_), do: :ok
end
