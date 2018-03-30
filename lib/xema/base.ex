defmodule Xema.Base do
  @moduledoc false

  import Xema.Utils, only: [update_id: 2]

  alias Xema.Ref
  alias Xema.Schema
  alias Xema.SchemaError
  alias Xema.Validator

  defmacro __using__(_opts) do
    quote do
      import Xema.Base

      @enforce_keys [:content]

      @type t :: %__MODULE__{
              content: __MODULE__.t()
            }

      defstruct [
        :content,
        :ids,
        :refs
      ]

      @spec new(any, keyword) :: Xema.t()
      def new(data, opts \\ []) do
        content = init(data, opts)

        struct(
          __MODULE__,
          content: content,
          ids: get_ids(content),
          refs: get_refs(content)
        )
      end

      @spec is_valid?(__MODULE__.t(), any) :: boolean
      def is_valid?(schema, value), do: validate(schema, value) == :ok

      @spec validate(__MODULE__.t() | Schema.t(), any) :: Validator.result()
      def validate(schema, value, opts \\ []) do
        case Validator.validate(schema, value, opts) do
          :ok ->
            :ok

          {:error, error} ->
            {:error, on_error(error)}
        end
      end

      defp on_error(error), do: error
      defoverridable on_error: 1

      defp get_refs(%Schema{} = schema) do
        refs =
          reduce(schema, %{id: nil}, fn
            %Ref{} = ref, acc, _path ->
              put_ref(acc, ref)

            %Schema{id: id}, acc, _path when not is_nil(id) ->
              update_id(acc, id)

            _, acc, _ ->
              acc
          end)

        refs = Map.delete(refs, :id)

        if refs == %{}, do: nil, else: refs
      end

      defp get_refs(_), do: nil

      defp put_ref(%{id: id} = acc, %Ref{remote: true, url: nil} = ref) do
        uri = update_id(id, ref.path)
        Map.put(acc, uri, get_schema(uri))
      end

      defp put_ref(acc, %Ref{remote: true, url: url, path: path}) do
        uri = Path.join(url, path)
        Map.put(acc, uri, get_schema(uri))
      end

      defp put_ref(map, _), do: map

      defp get_schema(uri) do
        with {:ok, src} <- get_response(uri),
             {:ok, data} <- remote(src) do
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
    end
  end

  def get_ids(%Schema{} = schema) do
    ids =
      reduce(schema, %{}, fn
        %Schema{id: id}, acc, path when not is_nil(id) ->
          Map.put(acc, id, Ref.new(path))

        _, acc, _ ->
          acc
      end)

    if ids == %{}, do: nil, else: ids
  end

  def get_ids(_), do: nil

  def get_response(uri) do
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      error ->
        {:error, error}
    end
  end

  #  defp evil(str) do
  #    {data, _} = Code.eval_string(str)
  #    {:ok, data}
  #  rescue
  #    error -> {:error, error}
  #  end

  def reduce(schema, acc, fun) do
    reduce(schema, acc, "#", fun)
  end

  def reduce(%Schema{} = schema, acc, path, fun) do
    schema
    |> Map.from_struct()
    |> Enum.reduce(fun.(schema, acc, path), fn {key, value}, x ->
      reduce(value, x, Path.join(path, to_string(key)), fun)
    end)
  end

  def reduce(%{__struct__: _} = struct, acc, path, fun),
    do: fun.(struct, acc, path)

  def reduce(map, acc, path, fun) when is_map(map) do
    Enum.reduce(map, fun.(map, acc, path), fn
      {%{__struct__: _}, _}, acc ->
        acc

      {key, value}, acc ->
        reduce(value, acc, Path.join(path, to_string(key)), fun)
    end)
  end

  def reduce(value, acc, path, fun), do: fun.(value, acc, path)
  #  end
  # end
end
