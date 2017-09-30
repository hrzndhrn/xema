defmodule Xema.List do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct [
    :items,
    :min_items,
    :max_items,
    :unique_items,
    additional_items: true,
    as: :list
  ]

  @type t :: %Xema.List{
    items: list | Xema.t,
    min_items: pos_integer,
    max_items: pos_integer,
    unique_items: boolean,
    additional_items: boolean,
    as: atom
  }

  @spec new(list) :: Xema.List.t
  def new(keywords), do: struct(Xema.List, keywords)
end
