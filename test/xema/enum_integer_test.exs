defmodule Xema.EnumIntegerTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  setup do
    list = [1, 2, 2.3]
    enum = Xema.create(:enum, list)
    schema = Xema.create(:integer, enum: enum)

    %{schema: schema, enum: enum, list: list}
  end

  test "type and properties", %{schema: schema, enum: enum} do
    assert schema.type == :integer
  end

  test "with a string", %{schema: schema, enum: enum} do
    assert validate(schema, "a") == {:error, %{type: :integer}}
  end

  test "with a float", %{schema: schema} do
    assert validate(schema, 2.3) == {:error, %{type: :integer}}
  end

  test "with a integer thats not in the enum", %{schema: schema, list: list} do
    assert validate(schema, 5) == {:error, %{enum: list}}
  end

  test "with a integer thats in the enum", %{schema: schema, list: list} do
    assert validate(schema, 2) == :ok
  end
end
