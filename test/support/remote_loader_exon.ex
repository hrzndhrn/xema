defmodule Test.RemoteLoaderExon do
  @moduledoc false

  @behaviour Xema.Loader

  @impl true
  def fetch(uri) do
    with {:ok, response} <- get(uri), do: eval(response, uri)
  end

  defp get(uri) do
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Remote schema '#{uri}' not found."}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, "code: #{code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp eval(str, uri) do
    {data, _} = Code.eval_string(str)
    {:ok, data}
  rescue
    error -> {:error, %{error | file: URI.to_string(uri)}}
  end
end
