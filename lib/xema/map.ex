defmodule Xema.Map do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct as: :map,
            string_keys: false

  alias Xema.Map

  @spec properties(list) :: %Map{}
  def properties(properties), do: struct(%Map{}, properties)

  @spec is_valid?(%Map{}, any) :: boolean
  def is_valid?(properties, map), do: validate(properties, map) == :ok

  @spec validate(%Map{}, any) :: :ok | {:error, atom, any}
  def validate(properties, map) do
    with :ok <- type(properties, map),
      do: :ok
  end

  defp type(_properties, map) when is_map(map), do: :ok
  defp type(properties, _map), do: {:error, :wrong_type, %{type: properties.as}}
end
