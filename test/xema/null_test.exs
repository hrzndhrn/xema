defmodule Xema.NullTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  test "any schema" do
    schema = Xema.create(:null)

    assert schema.type == :null
    assert schema.properties == nil

    assert is_valid?(schema, nil)
    refute is_valid?(schema, 1)
    refute is_valid?(schema, %{bla: 1})

    assert validate(schema, nil) == :ok
    assert validate(schema, 1) == {:error, :null}
    assert validate(schema, %{bla: 1}) == {:error, :null}
  end
end
