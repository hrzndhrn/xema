defmodule Test.RemoteLoaderJson do
  @moduledoc false

  @behaviour Xema.Loader

  require Logger

  alias Xema.JsonSchema

  @impl true
  def fetch(uri) do
    with {:ok, response} <- get(uri), do: eval(response)
  end

  defp get(%URI{host: "json-schema.org", path: "/draft-04/schema"}),
    do: File.read("test/support/json_schema/draft04.json")

  defp get(%URI{host: "json-schema.org", path: "/draft-06/schema"}),
    do: File.read("test/support/json_schema/draft06.json")

  defp get(%URI{host: "json-schema.org", path: "/draft-07/schema"}),
    do: File.read("test/support/json_schema/draft07.json")

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

  defp eval(json) do
    {:ok, Jason.decode!(json)}
  end
end
