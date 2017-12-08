defmodule Xema.EnumError do
  defexception [:message, :value, :enum]

  def exception(value, enum), do: new(value, enum)

  def tuple(value, enum), do: {:error, new(value, enum)}

  def new(value, enum),
    do: %Xema.EnumError{
      message: "Value #{inspect value} is not in enum #{inspect enum}.",
      value: value,
      enum: enum
    }
end

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
