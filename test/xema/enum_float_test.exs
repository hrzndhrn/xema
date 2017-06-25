defmodule Xema.EnumFloatTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  setup do
    list = [1, 1.1, 1.2]
    enum = Xema.create(:enum, list)
    schema = Xema.create(:float, enum: enum)

    %{schema: schema, enum: enum, list: list}
  end

  test "type and properties", %{schema: schema, enum: enum} do
    assert schema.type == :float
    assert schema.properties.enum == enum
  end

  describe "validate/2" do
    test "with a string", %{schema: schema},
      do: assert validate(schema, "a") == {:error, %{type: :float}}

    test "with a integer thats in the enum", %{schema: schema},
      do: assert validate(schema, 1) == {:error, %{type: :float}}

    test "with a float thats not in the enum", %{schema: schema, list: list},
      do: assert validate(schema, 1.5) == {:error, %{enum: list}}

    test "with a float thats in the enum", %{schema: schema},
      do: assert validate(schema, 1.2) == :ok
  end

  describe "is_valid?/2" do
    test "with a string", %{schema: schema},
      do: refute is_valid?(schema, "a")

    test "with a integer thats in the enum", %{schema: schema},
      do: refute is_valid?(schema, 1)

    test "with a float thats not in the enum", %{schema: schema},
      do: refute is_valid?(schema, 1.5)

    test "with a float thats in the enum", %{schema: schema},
      do: assert is_valid?(schema, 1.2)
  end
end
