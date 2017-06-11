defmodule Xema.AnyTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  test "any schema" do
    schema = Xema.create()

    assert schema.type == :any
    assert schema.properties == nil

    assert is_valid?(schema, "foo")
    assert is_valid?(schema, 1)
    assert is_valid?(schema, %{bla: 1})

    assert validate(schema, "foo") == :ok
    assert validate(schema, 1) == :ok
    assert validate(schema, %{bla: 1}) == :ok
  end
end
