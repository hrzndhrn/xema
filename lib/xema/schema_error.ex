defmodule Xema.SchemaError do
  defexception [:message]
end

defmodule Xema.TypeError do
  defexception [:message, :expected, :got]

  def exception(expected, got), do: new(expected, got)

  def tuple(expected, got), do: {:error, new(expected, got)}

  defp new(expected, got),
    do: %Xema.TypeError{
      message: "Expected #{inspect(expected.as)}, got #{inspect(got)}.",
      expected: expected.as,
      got: got
    }
end
