defmodule Xema.SchemaValidator do
  @moduledoc false

  @schema %Xema{
    content: %Xema.Schema{
      definitions: %{type: %Xema.Schema{enum: [:atom, :integer, :any, :tuple]}},
      items: [%Xema.Schema{ref: %Xema.Ref{pointer: "#/definitions/type"}}],
      max_items: 2,
      min_items: 2,
      type: :tuple
    }
  }

  def validate!(val) do
    case Xema.validate(@schema, val) do
      :ok ->
        :ok

      {:error, reason} ->
        raise "Error: #{inspect(reason)}"
    end
  end
end
