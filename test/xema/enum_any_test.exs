defmodule Xema.EnumAnyTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  setup do
    list = [1, 1.1, "a"]
    schema = Xema.create(:any, enum: list)

    %{schema: schema, list: list}
  end

  test "type and keywords", %{schema: schema, list: list} do
    assert schema.type == :any
    assert schema.keywords.enum == list
  end

  describe "validate/2" do
    test "with a string that's in the enum", %{schema: schema},
      do: assert validate(schema, "a") == :ok

    test "with a string that's not in the enum", %{schema: schema, list: list},
      do: assert validate(schema, "z") ==
        {:error, %{reason: :not_in_enum, enum: list}}

    test "with an integer that's in the enum", %{schema: schema},
      do: assert validate(schema, 1) == :ok

    test "with an integer that's not in the enum", %{schema: schema, list: list},
      do: assert validate(schema, 7) ==
        {:error, %{reason: :not_in_enum, enum: list}}

    test "with a float that's in the enum", %{schema: schema},
      do: assert validate(schema, 1.1) == :ok

    test "with a float that's not in the enum", %{schema: schema, list: list},
      do: assert validate(schema, 1.5) ==
        {:error, %{reason: :not_in_enum, enum: list}}
  end

  describe "is_valid?/2" do
    test "with a string that's in the enum", %{schema: schema},
      do: assert is_valid?(schema, "a")

    test "with a string that's not in the enum", %{schema: schema},
      do: refute is_valid?(schema, "z")

    test "with an integer that's in the enum", %{schema: schema},
      do: assert is_valid?(schema, 1)

    test "with an integer that's not in the enum", %{schema: schema},
      do: refute is_valid?(schema, 7)

    test "with a float that's in the enum", %{schema: schema},
      do: assert is_valid?(schema, 1.1)

    test "with a float that's not in the enum", %{schema: schema},
      do: refute is_valid?(schema, 1.5)
  end
end
