defmodule Amex.KeyValue do
  use Xema

  xema do
    map(
      keys: :strings,
      additional_properties: [:number, :string],
      property_names: [pattern: ~r/^[a-z][a-z_]*$/],
      default: %{}
    )
  end
end
