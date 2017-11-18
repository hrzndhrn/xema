defmodule Xema.SchemaValidator do
  @moduledoc false

  @spec validate(atom, keyword) :: :ok
  def validate(type, opts) do
    with :ok <- minimum(type, opts),
         :ok <- multiple_of(type, opts) do
      opts
    else
      error -> throw(error)
    end
  end

  # Keyword: minimum
  # The value of `minimum` must be a number, representing an inclusive upper
  # limit for a numeric instance.

  defp minimum(:number, minimum: value)
       when is_integer(value) or is_float(value),
       do: :ok

  defp minimum(:integer, minimum: value)
       when is_integer(value),
       do: :ok

  defp minimum(:float, minimum: value)
       when is_integer(value) or is_float(value),
       do: :ok

  defp minimum(:integer, minimum: value),
    do: {:error, "Expected an Integer for minimum, got #{inspect(value)}."}

  defp minimum(_, minimum: value),
    do: {:error, "Expected an Integer or Float for minimum, got #{inspect(value)}."}

  defp minimum(_, _), do: :ok


  # Keyword: multiple_of
  # The value of `multipleOf` must be a number, strictly greater than 0.

  defp multiple_of(:integer, multiple_of: value) when is_integer(value) do
    do_multiple_of(value)
  end

  defp multiple_of(:float, multiple_of: value)
       when is_float(value) or is_integer(value) do
    do_multiple_of(value)
  end

  defp multiple_of(:number, multiple_of: value)
       when is_float(value) or is_integer(value) do
    do_multiple_of(value)
  end

  defp multiple_of(:integer, multiple_of: value) do
    {
      :error,
      "Expected an Integer for multiple_of, got #{inspect(value)}."
    }
  end

  defp multiple_of(_, multiple_of: value) do
    {
      :error,
      "Expected an Integer or Float for multiple_of, got #{inspect(value)}."
    }
  end

  defp multiple_of(_, _), do: :ok

  @compile {:inline, do_multiple_of: 1}
  defp do_multiple_of(value) do
    case value > 0 do
      true -> :ok
      false -> {:error, "multiple_of must be strictly greater than 0."}
    end
  end
end
