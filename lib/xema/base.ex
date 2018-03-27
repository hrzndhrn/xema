defmodule Xema.Base do
  @moduledoc false

  alias Xema.Ref
  alias Xema.Schema
  alias Xema.SchemaError
  alias Xema.Validator

  defmacro __using__(_opts) do
    quote do
      @behaviour Xema.Base

      alias Xema.Base

      @enforce_keys [:content]

      @type t :: %__MODULE__{
              content: __MODULE__.t()
            }

      defstruct [
        :content,
        :ids,
        :refs
      ]

      @spec create(Xema.Schema.t()) :: __MODULE__.t()
      def create(schema) do
        raise "deprected"

        struct(
          __MODULE__,
          content: schema,
          ids: Base.get_ids(schema)
        )
      end

      @spec new(any, keyword) :: Xema.t()
      def new(data, opts \\ []), do: Base.__new__(__MODULE__, data, opts)

      @spec is_valid?(Xema.t(), any) :: boolean
      def is_valid?(schema, value), do: validate(schema, value) == :ok

      @spec validate(Xema.t() | Schema.t(), any) :: Validator.result()
      def validate(schema, value, opts \\ []),
        do: Validator.validate(schema, value, opts)
    end
  end

  @callback init(any, keyword) :: Xema.t()

  def __new__(module, data, opts) do
    content =
      case module.init(data, opts) do
        %Schema{} = schema ->
          schema

        %Ref{} = ref ->
          ref

        _ ->
          raise Xema.Error, message: "Function 'init' must return a schema."
      end

    struct(
      module,
      content: content,
      ids: get_ids(content),
      refs: get_refs(content)
    )
  end

  defp get_ids(%Schema{} = schema) do
    ids =
      reduce(schema, %{}, fn
        %Schema{id: id}, acc, path when not is_nil(id) ->
          Map.put(acc, id, Ref.new(path))

        _, acc, _ ->
          acc
      end)

    if ids == %{}, do: nil, else: ids
  end

  defp get_ids(_), do: nil

  defp get_refs(%Schema{} = schema) do
    refs =
      reduce(schema, %{}, fn
        %Ref{} = ref, acc, _path -> put_ref(acc, ref)
        _, acc, _ -> acc
      end)

    if refs == %{}, do: nil, else: refs
  end

  defp get_refs(_), do: nil

  defp put_ref(map, %Ref{pointer: "http" <> _ = pointer}) do
    uri = String.replace(pointer, ~r/#.*/, "")

    unless Regex.match?(~r/\..+/, uri) do
      map
    else
      case(get_schema(uri)) do
        nil -> map
        schema -> Map.put(map, uri, schema)
      end
    end
  end

  defp put_ref(map, _), do: map

  defp get_schema(uri) do
    with {:ok, src} <- get_response(uri),
         {:ok, data} <- evil(src) do
      Xema.new(data)
    else
      {:error, %SyntaxError{description: desc, line: line}} ->
        raise SyntaxError, description: desc, line: line, file: uri

      {:error, %CompileError{description: desc, line: line}} ->
        raise CompileError, description: desc, line: line, file: uri

      {:error, _error} ->
        raise SchemaError, message: "Remote schema '#{uri}' not found."
    end
  end

  defp get_response(uri) do
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      error ->
        {:error, error}
    end
  end

  defp evil(str) do
    {data, _} = Code.eval_string(str)
    {:ok, data}
  rescue
    error -> {:error, error}
  end

  defp reduce(schema, acc, fun) do
    reduce(schema, acc, "#", fun)
  end

  defp reduce(%Schema{} = schema, acc, path, fun) do
    schema
    |> Map.from_struct()
    |> Enum.reduce(fun.(schema, acc, path), fn {key, value}, x ->
      reduce(value, x, Path.join(path, to_string(key)), fun)
    end)
  end

  defp reduce(%{__struct__: _} = struct, acc, path, fun),
    do: fun.(struct, acc, path)

  defp reduce(map, acc, path, fun) when is_map(map) do
    Enum.reduce(map, fun.(map, acc, path), fn
      {%{__struct__: _}, _}, acc ->
        acc

      {key, value}, acc ->
        reduce(value, acc, Path.join(path, to_string(key)), fun)
    end)
  end

  defp reduce(value, acc, path, fun), do: fun.(value, acc, path)
end
