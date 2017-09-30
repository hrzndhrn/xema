defmodule Xema.Map do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct [
    :additional_properties,
    :max_properties,
    :min_properties,
    :properties,
    :required,
    :pattern_properties,
    :keys,
    :dependencies,
    as: :map
  ]

  @type t :: %Xema.Map{
    additional_properties: boolean,
    max_properties: pos_integer,
    min_properties: pos_integer,
    properties: map,
    required: list,
    pattern_properties: map,
    keys: atom,
    dependencies: list | map,
    as: atom
  }

  @spec new(keyword) :: Xema.Map.t
  def new(keywords) do
    keywords = Keyword.update(keywords, :required, nil, &(MapSet.new(&1)))
    struct(Xema.Map, keywords)
  end
end
