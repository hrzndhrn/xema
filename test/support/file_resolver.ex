defmodule Test.FileResolver do
  @moduledoc false

  @behaviour Xema.Resolver

  @spec fetch(binary) :: {:ok, map} | {:error, any}
  def fetch(uri),
    do:
      "test/support/remote"
      |> Path.join(uri.path)
      |> File.read!()
      |> eval(uri)

  defp eval(str, uri) do
    {data, _} = Code.eval_string(str)
    {:ok, data}
  rescue
    error -> {:error, %{error | file: URI.to_string(uri)}}
  end
end
