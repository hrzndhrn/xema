defmodule Amex.Multi do
  use Xema, multi: true

  xema :pos do
    number(minimum: 0)
  end

  @default true
  xema :neg do
    number(maximum: 0)
  end
end
