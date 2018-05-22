defmodule Xema.Ref do
  @moduledoc """
  This module contains a struct and function to represent and handle references.
  """

  import Xema.Utils, only: [get_value: 2, update_nil: 2]

  alias Xema.Ref
  alias Xema.Schema
  alias Xema.SchemaError

  require Logger

  @type t :: %Xema.Ref{
          path: String.t() | nil,
          pointer: String.t(),
          remote: boolean(),
          url: String.t() | nil
        }

  defstruct pointer: nil,
            path: nil,
            remote: false,
            url: nil

  @doc """
  Creates a new reference from the given `pointer`.

  ## Examples

      iex> Xema.Ref.new("http://foo.com/bar/baz.exon#/definitions/abc")
      %Xema.Ref{
        path: "/bar/baz.exon",
        pointer: "/definitions/abc",
        remote: true,
        url: "http://foo.com:80"
      }

  """
  @spec new(String.t()) :: Ref.t()
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

  @doc """
  Validates the given value with the referenced schema.
  """
  @spec validate(Ref.t(), any, keyword) :: :ok | {:error, map}
  def validate(ref, value, opts) do
    case get(ref, opts) do
      {:ok, %Schema{} = schema, opts} ->
        Xema.validate(schema, value, opts)

      {:ok, %Ref{} = ref, opts} ->
        validate(ref, value, opts)

      {:error, :not_found} ->
        raise SchemaError,
          message: "Reference '#{Ref.get_pointer(ref)}' not found."
    end
  end

  defp get(%Ref{remote: false, path: nil, pointer: pointer}, opts) do
    with {:ok, schema} <- do_get(pointer, opts[:root]), do: {:ok, schema, opts}
  end

  defp get(%Ref{remote: false, path: path, pointer: nil}, opts) do
    id =
      opts[:id]
      |> URI.parse()
      |> Map.put(:path, Path.join("/", path))
      |> URI.to_string()

    with {:ok, ref} <- get_ref(opts[:root], id), do: {:ok, ref, opts}
  end

  defp get(%Ref{remote: true, url: nil, path: path, pointer: pointer}, opts) do
    uri = URI.parse(opts[:id])

    uri =
      case is_nil(uri.path) || !String.ends_with?(uri.path, "/") do
        true -> Map.put(uri, :path, Path.join("/", path))
        false -> Map.put(uri, :path, Path.join(uri.path, path))
      end

    # xema = Map.get(opts[:root].refs, URI.to_string(uri))

    with {:ok, xema} <- get_xema(opts[:root], URI.to_string(uri)),
         {:ok, schema} <- do_get(pointer, xema),
         do: {:ok, schema, root: xema}
  end

  defp get(%Ref{remote: true, url: url, path: path, pointer: pointer}, opts) do
    uri = Path.join(url, path)

    # xema = Map.get(opts[:root].refs, uri)

    with {:ok, xema} <- get_xema(opts[:root], uri),
         {:ok, schema} <- do_get(pointer, xema),
         do: {:ok, schema, root: xema}
  end

  defp get(_ref, _opts), do: {:error, :not_found}

  defp do_get(_, nil), do: {:error, :not_found}

  defp do_get(pointer, %{__struct__: _, content: content}) do
    case pointer in [nil, "", "#"] do
      true -> {:ok, content}
      false -> do_get(pointer, content)
    end
  end

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

  defp get_ref(%{ids: refs}, id) do
    case Map.get(refs, id) do
      nil -> {:error, :not_found}
      ref -> {:ok, ref}
    end
  end

  defp get_ref(_, _), do: {:error, :not_found}

  defp get_xema(%{refs: xemas}, pointer) do
    case Map.get(xemas, pointer) do
      nil -> {:error, :not_found}
      xema -> {:ok, xema}
    end
  end

  defp get_xema(_, _), do: {:error, :not_found}

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

  @doc """
  Returns the `pointer` of the given reference.
  """
  @spec get_pointer(Ref.t()) :: String.t()
  def get_pointer(ref) do
    ref.url
    |> update_nil("")
    |> URI.parse()
    |> Map.put(:path, ref.path)
    |> Map.put(:fragment, ref.pointer)
    |> URI.to_string()
  end

  @doc """
  Returns the binary representation of a reference.

  ## Examples

      iex> "http://foo.com/bar/baz.exon#/definitions/abc"
      ...> |> Xema.Ref.new()
      ...> |> Xema.Ref.to_string()
      "{:ref, \\"http://foo.com/bar/baz.exon#/definitions/abc\\"}"

  """
  @spec to_string(Ref.t()) :: String.t()
  def to_string(ref), do: "{:ref, #{inspect(get_pointer(ref))}}"
end

defimpl String.Chars, for: Xema.Ref do
  @spec to_string(Xema.Ref.t()) :: String.t()
  def to_string(ref), do: Xema.Ref.to_string(ref)
end
