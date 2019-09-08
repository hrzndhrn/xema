defmodule Amex.User do
  use Xema

  alias Amex.{Grant, KeyValue, Location, UnixTimestamp}

  @regex_uuid ~r/^[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}$/

  xema do
    field :id, :string, default: {UUID, :uuid4}, pattern: @regex_uuid
    field :name, :string, min_length: 1
    field :age, [:integer, nil], minimum: 0
    field :location, Location
    field :grants, :list, items: Grant, default: []
    field :settings, KeyValue
    field :created, DateTime, caster: UnixTimestamp
    field :updated, DateTime, caster: UnixTimestamp, allow: nil
    required [:age]
  end
end
