defmodule Xema.List do
  @moduledoc """
  TODO
  """

  defstruct [
    :items,
    :min_items,
    :max_items,
    :unique_items,
    additional_items: true,
    as: :list
  ]

  @type t :: %Xema.List{
    items: list | Xema.t | nil,
    min_items: pos_integer | nil,
    max_items: pos_integer | nil,
    unique_items: boolean | nil,
    additional_items: boolean | nil,
    as: atom
  }
end
