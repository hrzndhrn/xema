defmodule Xema.TestSupport do

  def as(schema, type), do: schema.keywords.as === type
  def type(schema, type), do: schema.type === type
end
