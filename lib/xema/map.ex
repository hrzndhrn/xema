defmodule Xema.Map do
  @moduledoc """
  This module contains the struct for the keywords of type `map`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :map
      %Xema{type: %Xema.Map{}}
      iex> schema.type == %Xema.Map{}
      true
  """

  @typedoc """
  The struct contains the keywords for the type `map`.

  * `additional_properties` disallow additional properties, if set to true
  * `as` is used in an error report. Default of `as` is `:list`
  * `dependencies` allows the schema of the map to change based on the
    presence of certain special properties
  * `keys` could be `:atoms` or `:strings`
  * `max_properties` the maximum count of properties for the map
  * `min_properties` the minimal count of properties for the map
  * `pattern_properties` specifies schemas for properties by patterns
  * `properties` specifies schemas for properties
  * `required` contains a set of required properties
  """
  @type t :: %Xema.Map{
          additional_properties: map | boolean | nil,
          max_properties: pos_integer | nil,
          min_properties: pos_integer | nil,
          properties: map | nil,
          required: MapSet.t() | nil,
          pattern_properties: map | nil,
          keys: atom | nil,
          dependencies: list | map | nil,
          as: atom
        }

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

  @spec new(keyword) :: Xema.Map.t()
  def new(opts \\ []), do: struct(Xema.Map, update(opts))

  defp update(opts) do
    opts
    |> Keyword.update(:properties, nil, &properties/1)
    |> Keyword.update(:pattern_properties, nil, &properties/1)
    |> Keyword.update(:dependencies, nil, &dependencies/1)
    |> Keyword.update(:additional_properties, nil, &additional_properties/1)
    |> Keyword.update(:required, nil, &MapSet.new(&1))
  end

  defp properties(map) do
    Enum.into(map, %{}, fn {key, prop} -> {key, Xema.type(prop)} end)
  end

  defp dependencies(map) do
    Enum.into(map, %{}, fn
      {key, dep} when is_list(dep) -> {key, dep}
      {key, dep} -> {key, Xema.type(dep)}
    end)
  end

  defp additional_properties(additional_properties)
       when is_boolean(additional_properties),
       do: additional_properties

  defp additional_properties(additional_properties), do: Xema.type(additional_properties)
end
