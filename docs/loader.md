# Configure a loader

A loader returns the data for a remote schema. The remote schemas are defined
in a schema like this.

```elixir
...
  properties: %{
    int: {:ref, "http://localhost:1234/int.exon"}
  }
...
```

A loader will be configured like this.

```elixir
config :xema, loader: My.Loader
```

A loader is a module which use the behaviour `Xema.Loader`.

```elixir
defmodule My.Loader do
  @moduledoc false

  @behaviour Xema.Loader

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
```

The function `fetch/1` will be called by `Xema` and expects an `%URI{}`. The
return value must be a tuple of `:ok` and the required data for a schema or an
error tuple.

**Note!** This loader use `Code.eval_string/1` and eval is always evil.

> **Warning:** string can be any Elixir code and will be executed with the same
> privileges as the Erlang VM: this means that such code could compromise the
> machine (for example by executing system commands). Don’t use `eval_string/3`
> with untrusted input (such as strings coming from the network).
> -- Elixir API

## File loader

A loader to read schema from the local file system.

In the schema:
```elixir
...
  properties: %{
    int: {:ref, "int.exon"}
  }
...
```

The loader:
```elixir
defmodule My.Loader do
  @moduledoc false

  @behaviour Xema.Loader

  @spec fetch(binary) :: {:ok, map} | {:error, any}
  def fetch(uri) do
    "path/to/schemas"
    |> Path.join(uri.path)
    |> File.read!()
    |> eval(uri)
  end

  defp eval(str, uri) do
    {data, _} = Code.eval_string(str)
    {:ok, data}
  rescue
    error -> {:error, %{error | file: URI.to_string(uri)}}
  end
end
```

## JSON Schema loader

If the scheme is created with `Xema.from_json_schema/2`, the loader must return
the decoded JSON.

In this case the file loader looks like this:
```elixir
defmodule My.Loader do
  @moduledoc false

  @behaviour Xema.Loader

  @spec fetch(binary) :: {:ok, map} | {:error, any}
  def fetch(uri) do
    "path/to/schemas"
    |> Path.join(uri.path)
    |> File.read!()
    |> Jason.decode()
  end
end
```
