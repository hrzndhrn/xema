defmodule Xema.EnumTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  test "any schema" do
    list = ["a", 1]
    schema = Xema.create(:enum, list: list)

    assert schema.type == :enum
    assert schema.properties == %Xema.Enum{list: list}

    assert is_valid?(schema, "a")
    refute is_valid?(schema, "b")
    assert is_valid?(schema, 1)
    refute is_valid?(schema, 2)
    refute is_valid?(schema, %{bla: 1})

    assert validate(schema, "a") == :ok
    assert validate(schema, "b") == {:error, {:enum, list}}
    assert validate(schema, 1) == :ok
    assert validate(schema, 2) == {:error, {:enum, list}}
    assert validate(schema, %{bla: 1}) == {:error, {:enum, list}}
  end
end
