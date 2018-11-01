defmodule Xema.SchemaError do
  alias Xema.SchemaError

  defexception [:message, :reason]

  @impl true
  def exception(reason) when is_binary(reason) do
    %SchemaError{message: reason, reason: nil}
  end

  def exception(:missing_type = reason) do
    message = "Missing type."

    %SchemaError{message: message, reason: reason}
  end

  def exception({:invalid_type, type} = reason) do
    message = "Invalid type #{inspect(type)}."

    %SchemaError{message: message, reason: reason}
  end

  def exception({:invalid_types, types} = reason) do
    message = "Invalid types #{inspect(types)}."

    %SchemaError{message: message, reason: reason}
  end

  def exception(%{__struct__: SyntaxError} = error), do: error

  def exception(%{__struct__: CompileError} = error), do: error

  def exception(reason) do
    message =
      "Can't build schema! Reason:\n#{
        reason |> inspect() |> Code.format_string!()
      }"

    %SchemaError{message: message, reason: reason}
  end
end
