defmodule Xema.EnumStringTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  setup do
    list = ["foo", "bar"]
    schema = Xema.create(:string, enum: list)

    %{schema: schema, list: list}
  end

  test "type and keywords", %{schema: schema, list: list} do
    assert schema.type == :string
    assert schema.keywords.enum == list
  end

  describe "validate/2" do
    test "with a map", %{schema: schema},
      do: assert validate(schema, %{}) ==
        {:error, %{reason: :wrong_type, type: :string}}

    test "with a float", %{schema: schema},
      do: assert validate(schema, 2.3) ==
        {:error, %{reason: :wrong_type, type: :string}}

    test "with a string thats not in the enum", %{schema: schema, list: list},
      do: assert validate(schema, "no") ==
        {:error, %{reason: :not_in_enum, enum: list}}

    test "with a string thats in the enum", %{schema: schema},
      do: assert validate(schema, "foo") == :ok
  end

  describe "is_valid?/2" do
    test "with a float", %{schema: schema},
      do: refute is_valid?(schema, 2.3)

    test "with a string thats not in the enum", %{schema: schema},
      do: refute is_valid?(schema, "no")

    test "with a string thats in the enum", %{schema: schema},
      do: assert is_valid?(schema, "foo")
  end
end
