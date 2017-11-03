defmodule Xema.Map do
  @moduledoc """
  TODO
  """

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
          additional_properties: boolean | nil,
          max_properties: pos_integer | nil,
          min_properties: pos_integer | nil,
          properties: map | nil,
          required: MapSet.t() | nil,
          pattern_properties: map | nil,
          keys: atom | nil,
          dependencies: list | map | nil,
          as: atom
        }
end
