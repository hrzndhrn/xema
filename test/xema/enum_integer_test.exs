defmodule Xema.EnumIntegerTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  setup do
    list = [1, 2, 2.3]
    enum = Xema.create(:enum, list)
    schema = Xema.create(:integer, enum: enum)

    %{schema: schema, enum: enum, list: list}
  end

  test "type and keywords", %{schema: schema, enum: enum} do
    assert schema.type == :integer
    assert schema.keywords.enum == enum
  end

  describe "validate/2" do
    test "with a string", %{schema: schema},
      do: assert validate(schema, "a") == {:error, :wrong_type, %{type: :integer}}

    test "with a float", %{schema: schema},
      do: assert validate(schema, 2.3) == {:error, :wrong_type, %{type: :integer}}

    test "with a integer thats not in the enum", %{schema: schema, list: list},
      do: assert validate(schema, 5) == {:error, :not_in_enum, %{enum: list}}

    test "with a integer thats in the enum", %{schema: schema},
      do: assert validate(schema, 2) == :ok
  end

  describe "is_valid?/2" do
    test "with a string", %{schema: schema},
      do: refute is_valid?(schema, "a")

    test "with a float", %{schema: schema},
      do: refute is_valid?(schema, 2.3)

    test "with a integer thats not in the enum", %{schema: schema},
      do: refute is_valid?(schema, 5)

    test "with a integer thats in the enum", %{schema: schema},
      do: assert is_valid?(schema, 2)
  end
end
