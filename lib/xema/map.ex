defmodule Xema.Map do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct as: :map,
            string_keys: false

  alias Xema.Map

  @spec keywords(list) :: %Map{}
  def keywords(keywords), do: struct(%Map{}, keywords)

  @spec is_valid?(%Map{}, any) :: boolean
  def is_valid?(keywords, map), do: validate(keywords, map) == :ok

  @spec validate(%Map{}, any) :: :ok | {:error, atom, any}
  def validate(keywords, map) do
    with :ok <- type(keywords, map),
      do: :ok
  end

  defp type(_keywords, map) when is_map(map), do: :ok
  defp type(keywords, _map), do: {:error, :wrong_type, %{type: keywords.as}}
end
