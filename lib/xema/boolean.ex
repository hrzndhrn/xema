defmodule Xema.Boolean do
  @moduledoc """
  TODO
  """

  @behaviour Xema

  defstruct [as: :boolean]

  @type keywords :: %Xema.Boolean{as: atom}

  @spec new(keyword) :: Xema.Boolean.keywords
  def new(keywords), do: struct(Xema.Boolean, keywords)
end
