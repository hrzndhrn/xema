defmodule Amex.Multi do
  use Xema, multi: true, default: :neg

  xema :pos do
    number(minimum: 0)
  end

  xema :neg do
    number(maximum: 0)
  end
end
