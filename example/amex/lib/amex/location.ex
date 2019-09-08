defmodule Amex.Location do
  use Xema

  xema do
    field :city, [:string, nil]
    field :country, [:string, nil], min_length: 1
  end
end
