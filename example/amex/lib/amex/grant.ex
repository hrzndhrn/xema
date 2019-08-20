defmodule Amex.Grant do
  use Xema

  @ops [:foo, :bar, :baz]
  @permissions [:create, :read, :update, :delete]

  xema do
    field(:op, :atom, enum: @ops)
    field(:permissions, :list, items: {:atom, enum: @permissions})
    required([:op, :permissions])
  end
end
