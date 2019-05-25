defmodule AssertBlame do
  @moduledoc false

  import ExUnit.Assertions

  def assert_blame(exception, fun), do: assert_blame(exception, nil, fun)

  def assert_blame(exception, message, fun) do
    fun.()
  rescue
    e ->
      actual_exception = e.__struct__

      assert exception == actual_exception,
             "Expected exception #{inspect(exception)} but got #{inspect(e)}"

      if message != nil do
        actual_message =
          Exception.blame(:error, e, __STACKTRACE__) |> elem(0) |> Exception.message()

        assert message == actual_message,
               """
               Wrong message for #{inspect(exception)}
               expected:\n#{message}
               actual:\n#{actual_message}\
               """
      end
  else
    _ -> flunk("Expected exception #{inspect(exception)} but nothing was raised")
  end
end
