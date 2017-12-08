defmodule Xema.EnumError do
  defexception [:message, :enum, :value]

  def exception(enum, value), do: new(enum, value)

  def tuple(enum, value), do: {:error, new(enum, value)}

  def new(enum, value),
    do: %Xema.EnumError{
      message: "Value #{inspect(value)} is not in enum #{inspect(enum)}.",
      value: value,
      enum: enum
    }
end

defmodule Xema.SchemaError do
  defexception [:message]
end

defmodule Xema.TypeError do
  defexception [:message, :type, :value]

  def exception(type, value), do: new(type, value)

  def tuple(type, value), do: {:error, new(type, value)}

  defp new(type, value),
    do: %Xema.TypeError{
      message: "Expected #{inspect(type.as)}, got #{inspect(value)}.",
      type: type.as,
      value: value
    }
end
