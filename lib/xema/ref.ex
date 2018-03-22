defmodule Xema.Ref do
  @moduledoc """
  TODO: doc
  """

  import Xema.Utils, only: [get_value: 2]

  alias Xema.Ref
  alias Xema.Schema

  @type t :: %Xema.Ref{pointer: String.t()}

  defstruct pointer: ""

  @spec new(keyword | String.t()) :: Ref.t()
  def new(str) when is_binary(str), do: %Ref{pointer: str}

  def new(opts), do: struct(Ref, opts)

  def get(%Ref{pointer: "#"}, %Schema{} = schema), do: {:ok, schema}

  def get(%Ref{pointer: "#"}, %{content: schema}), do: {:ok, schema}

  def get(%Ref{pointer: "#/" <> pointer}, %Schema{} = schema),
    do:
      pointer
      |> String.split("/")
      |> do_get(schema)

  def get(ref, %{content: schema}), do: get(ref, schema)

  defp do_get(_, nil), do: {:error, :not_found}

  defp do_get([], schema), do: {:ok, schema}

  defp do_get([step | steps], schema) do
    case get_value(schema, step) do
      {:ok, value} -> do_get(steps, value)
      {:error, _} -> {:error, :not_found}
    end
  end
end
