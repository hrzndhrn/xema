defmodule Xema.EnumError do
  defexception [:message, :value, :enum]

  def exception(value, enum), do: new(value, enum)

  def tuple(value, enum), do: {:error, new(value, enum)}

  def new(value, enum),
    do: %Xema.EnumError{
      message: "Value #{inspect(value)} is not in enum #{inspect(enum)}.",
      value: value,
      enum: enum
    }
end

defmodule Xema.RangeError do
  defexception [
    :message,
    :value,
    :maximum,
    :minimum,
    :exclusive_maximum,
    :exclusive_minimum
  ]

  def exception(value, keywords), do: new(value, keywords)

  def tuple(value, keywords), do: {:error, new(value, keywords)}

  def new(value, keywords),
    do: %Xema.RangeError{
      message: message(value, keywords),
      exclusive_maximum: keywords[:exclusive_maximum],
      exclusive_minimum: keywords[:exclusive_minimum],
      maximum: keywords[:maximum],
      minimum: keywords[:minimum],
      value: value
    }

  defp message(value, keywords)
       when is_list(keywords),
       do: message(value, Enum.into(keywords, %{}))

  defp message(value, %{exclusive_maximum: true, maximum: maximum}),
    do:
      "Expected a value with an exclusive maximum of #{maximum}, got #{value}."

  defp message(value, %{exclusive_maximum: maximum})
       when is_number(maximum),
       do:
         "Expected a value with an exclusive maximum of #{maximum}, got #{value}."

  defp message(value, %{maximum: maximum}),
    do: "Expected a value with a maximum of #{maximum}, got #{value}."

  defp message(value, %{exclusive_minimum: true, minimum: minimum}),
    do:
      "Expected a value with an exclusive minimum of #{minimum}, got #{value}."

  defp message(value, %{exclusive_minimum: minimum})
       when is_number(minimum),
       do:
         "Expected a value with an exclusive minimum of #{minimum}, got #{value}."

  defp message(value, %{minimum: minimum}),
    do: "Expected a value with a minimum of #{minimum}, got #{value}."
end

defmodule Xema.SchemaError do
  defexception [:message]
end

defmodule Xema.TypeError do
  defexception [:message, :value, :type]

  def exception(value, type), do: new(value, type)

  def tuple(value, type), do: {:error, new(value, type)}

  defp new(value, type),
    do: %Xema.TypeError{
      message: "Expected #{inspect(type.as)}, got #{inspect(value)}.",
      type: type.as,
      value: value
    }
end
