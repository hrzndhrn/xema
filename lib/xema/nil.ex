defmodule Xema.Nil do
  @moduledoc false

  @behaviour Xema

  defstruct as: :nil

  @type t :: %Xema.Nil{as: atom}

  @spec new(list) :: Xema.Nil.t
  def new(keywords), do: struct(Xema.Nil, keywords)
end
