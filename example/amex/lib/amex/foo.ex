defmodule Amex.Foo do
  use Xema, multi: true

  xema :foo_schemaa do
    map(
      keys: :atoms,
      properties: %{
        network: {:string, min_length: 1}
      }
    )
  end
end
