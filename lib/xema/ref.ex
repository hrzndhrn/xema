defmodule Xema.Ref do
  @moduledoc """
  TODO: doc
  """

  import Xema.Utils, only: [get_value: 2, update_nil: 2]

  alias Xema.Ref
  alias Xema.Schema

  require Logger

  @type t :: %Xema.Ref{pointer: String.t()}

  defstruct pointer: nil,
            path: nil,
            remote: false,
            url: nil

  @spec new(keyword | String.t()) :: Ref.t()
  def new(pointer) when is_binary(pointer) do
    uri = URI.parse(pointer)
    path = uri |> Map.get(:path)
    pointer = uri |> Map.get(:fragment)
    remote = !is_nil(path) && Regex.match?(~r/(?:\..+#)|(?:\..+$)/, path)

    url =
      unless is_nil(uri.scheme) do
        port =
          if is_nil(uri.port),
            do: "",
            else: ":#{Integer.to_string(uri.port)}"

        "#{uri.scheme}://#{uri.host}#{port}"
      end

    %Ref{
      pointer: pointer,
      path: path,
      remote: remote,
      url: url
    }
  end

  def new(%URI{} = uri) do
    raise "deprecated"
    %Ref{pointer: URI.to_string(uri)}
  end

  def new(opts) when is_list(opts) do
    raise "deprecated"
    struct(Ref, opts)
  end

  def validate(ref, value, opts) do
    case get_x(ref, opts) do
      {:ok, %Schema{} = schema, opts} ->
        Xema.validate(schema, value, opts)

      {:ok, %Ref{} = ref, opts} ->
        validate(ref, value, opts)

      _error ->
        {:error, :ref_not_found}
        # _error -> {:error, ref}
    end
  end

  defp get_x(%Ref{remote: false, path: nil, pointer: pointer}, opts) do
    with {:ok, schema} <- do_get(pointer, opts[:root]), do: {:ok, schema, opts}
  end

  defp get_x(%Ref{remote: false, path: path, pointer: nil}, opts) do
    id =
      opts[:id]
      |> URI.parse()
      |> Map.put(:path, Path.join("/", path))
      |> URI.to_string()

    ref = Map.get(opts[:root].ids, id)

    {:ok, ref, opts}
  end

  defp get_x(%Ref{remote: true, url: nil, path: path, pointer: pointer}, opts) do
    uri = URI.parse(opts[:id])

    uri =
      case is_nil(uri.path) || !String.ends_with?(uri.path, "/") do
        true -> Map.put(uri, :path, Path.join("/", path))
        false -> Map.put(uri, :path, Path.join(uri.path, path))
      end

    xema = Map.get(opts[:root].refs, URI.to_string(uri))

    with {:ok, schema} <- do_get(pointer, xema), do: {:ok, schema, root: xema}
  end

  defp get_x(%Ref{remote: true, url: url, path: path, pointer: pointer}, opts) do
    uri = Path.join(url, path)

    xema = Map.get(opts[:root].refs, uri)

    with {:ok, schema} <- do_get(pointer, xema), do: {:ok, schema, root: xema}
  end

  defp get_x(_ref, _opts), do: {:error, :not_found}

  defp do_get(_, nil), do: {:error, :not_found}

  defp do_get(nil, %Xema{} = xema), do: {:ok, xema.content}

  defp do_get("#", xema), do: {:ok, get_schema(xema)}

  defp do_get("", xema), do: {:ok, get_schema(xema)}

  defp do_get(pointer, %Xema{} = xema), do: do_get(pointer, xema.content)

  defp do_get(pointer, schema)
       when is_binary(pointer),
       do:
         pointer
         |> String.trim("/")
         |> String.split("/")
         |> do_get(schema)

  defp do_get([], schema), do: {:ok, schema}

  defp do_get([step | steps], schema) when is_map(schema) do
    case get_value(schema, decode(step)) do
      {:ok, value} ->
        do_get(steps, value)

      {:error, _} ->
        {:error, :not_found}
    end
  end

  defp do_get([step | steps], schema) when is_list(schema) do
    with {:ok, index} <- to_integer(step) do
      case Enum.at(schema, index) do
        nil -> {:error, :not_found}
        value -> do_get(steps, value)
      end
    end
  end

  defp get_schema(schema) do
    case schema do
      %Xema{content: schema} -> schema
      %Schema{} = schema -> schema
    end
  end

  defp decode(str) do
    str
    |> String.replace("~0", "~")
    |> String.replace("~1", "/")
    |> URI.decode()
  rescue
    _ -> str
  end

  defp to_integer(str) do
    case Regex.run(~r/\d+/, str) do
      nil -> {:error, :not_found}
      [int] -> {:ok, String.to_integer(int)}
    end
  end

  def get_pointer(ref) do
    ref.url
    |> update_nil("")
    |> URI.parse()
    |> Map.put(:path, ref.path)
    |> Map.put(:fragment, ref.pointer)
    |> URI.to_string()
  end

  def to_string(ref), do: "{:ref, #{inspect(get_pointer(ref))}}"
end

defimpl String.Chars, for: Xema.Ref do
  @spec to_string(Xema.Ref.t()) :: String.t()
  def to_string(ref), do: Xema.Ref.to_string(ref)
end
