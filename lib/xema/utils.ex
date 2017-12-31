defmodule Xema.Utils do
  @moduledoc false

  @spec update(keyword) :: keyword
  def update(opts) do
    opts
    |> Keyword.update(:all_of, nil, &schemas/1)
    |> Keyword.update(:any_of, nil, &schemas/1)
    |> Keyword.update(:not, nil, fn schema -> Xema.type(schema) end)
    |> Keyword.update(:one_of, nil, &schemas/1)
  end

  @spec schemas(list) :: list
  defp schemas(list), do: Enum.map(list, fn schema -> Xema.type(schema) end)
end
