defmodule Xema.BooleanTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  test "boolean schema" do
    schema = Xema.create(:boolean)

    assert schema.type == :boolean
    assert schema.keywords == %Xema.Boolean{}

    assert is_valid?(schema, true)
    assert is_valid?(schema, false)
    refute is_valid?(schema, "true")
    refute is_valid?(schema, 1)
    refute is_valid?(schema, %{bla: 1})

    assert validate(schema, true) == :ok
    assert validate(schema, false) == :ok
    assert validate(schema, %{bla: 1}) == {:error, %{type: :boolean}}
  end
end
