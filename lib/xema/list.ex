defmodule Xema.List do
  @moduledoc """
  This module contains the struct for the keywords of type `list`.

  Usually this struct will be just used by `xema`.

  ## Examples

      iex> import Xema
      Xema
      iex> schema = xema :list
      %Xema{type: %Xema.List{}}
      iex> schema.type == %Xema.List{}
      true
  """

  @typedoc """
  The struct contains the keywords for the type `list`.

  * `additional_items` disallow additional items, if set to true
  * `as` is used in an error report. Default of `as` is `:list`
  * `items` specifies the type(s) of the items
  * `max_items` the maximum length of list
  * `min_items` the minimal length of list
  * `unique_items` disallow duplicate items, if set to true
  """

  @type t :: %Xema.List{
          items: list | Xema.t() | nil,
          min_items: pos_integer | nil,
          max_items: pos_integer | nil,
          unique_items: boolean | nil,
          additional_items: boolean | nil,
          as: atom
        }

  defstruct [
    :items,
    :min_items,
    :max_items,
    :unique_items,
    additional_items: true,
    as: :list
  ]
end
