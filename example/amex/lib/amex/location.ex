defmodule Amex.Location do
  use Xema

  xema_struct do
    field :city, [:string, nil]
    field :country, [:string, nil], min_length: 1
  end
end
