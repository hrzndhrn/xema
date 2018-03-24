defmodule Xema.Base do
  @moduledoc false

  alias Xema.Ref
  alias Xema.Schema

  defmacro __using__(_opts) do
    quote do
      @behaviour Xema.Base
      # def hello(name), do: "Hi, #{name}"
      alias Xema.Base

      @enforce_keys [:content]

      @type t :: %__MODULE__{
              content: Xema.Schema.t()
            }

      defstruct [
        :content,
        :ids
      ]

      @spec create(Xema.Schema.t()) :: __MODULE__.t()
      def create(schema) do
        struct(__MODULE__, content: schema, ids: Base.get_ids(schema))
      end
    end
  end

  @callback is_valid?(struct, any) :: boolean
  @callback validate(struct, any) :: Xema.Validator.result()

  def get_ids(schema) do
    case get_ids(schema, "#", %{}) do
      ids when ids == %{} -> nil
      ids -> ids
    end
  end

  defp get_ids(%Schema{} = schema, path, ids) do
    get_ids(
      Map.from_struct(schema),
      path,
      add_id(ids, schema, path)
    )
  end

  defp get_ids(%{__struct__: _}, _, ids), do: ids

  defp get_ids(values, path, ids) when is_map(values) do
    Enum.reduce(values, ids, fn
      {%{__struct__: _}, _}, acc -> acc
      {key, value}, acc -> get_ids(value, Path.join(path, to_string(key)), acc)
    end)
  end

  defp get_ids(values, path, ids) when is_list(values) do
    values
    |> Enum.with_index()
    |> Enum.reduce(ids, fn {value, key}, acc ->
      get_ids(value, Path.join(path, to_string(key)), acc)
    end)
  end

  defp get_ids(_, _, ids), do: ids

  defp add_id(ids, %Schema{id: id}, path) when is_binary(id) do
    Map.put(ids, id, Ref.new(path))
  end

  defp add_id(ids, _, _), do: ids
end
