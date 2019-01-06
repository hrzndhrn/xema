defmodule Test.Resolver do
  @moduledoc false

  @behaviour Xema.Resolver

  defmodule RemoteResolver do
    @moduledoc false

    @behaviour Xema.Resolver

    @spec fetch(binary) :: {:ok, map} | {:error, any}
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

  defmodule FileResolver do
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

  @spec fetch(binary) :: {:ok, map} | {:error, any}
  def fetch(uri) do
    case uri.host do
      nil -> FileResolver.fetch(uri)
      _ -> RemoteResolver.fetch(uri)
    end
  end
end
