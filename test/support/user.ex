defmodule Test.User do
  @moduledoc false

  defstruct [:name, :age]
end

defimpl Xema.Castable, for: Test.User do
  def cast(user, _), do: {:ok, user}
end
