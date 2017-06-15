defmodule Xema.FloatTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  test "number schema with minimum" do
    schema = Xema.create(:float, minimum: 1.2)

    assert schema.type == :float
    assert schema.properties == %Xema.Float{minimum: 1.2}

    refute is_valid?(schema, 1.1)
    assert is_valid?(schema, 1.2)
    assert is_valid?(schema, 1.3)
    refute is_valid?(schema, "1")

    assert validate(schema, 1.1) == {:error, %{minimum: 1.2}}
    assert validate(schema, 1.2) == :ok
    assert validate(schema, 1.3) == :ok
    assert validate(schema, "1") == {:error, %{type: :float}}
  end

  test "number schema with minimum and exclusive minimum" do
    schema = Xema.create(:float, minimum: 1.2, exclusive_minimum: true)

    assert schema.type == :float
    assert schema.properties == %Xema.Float{
      minimum: 1.2,
      exclusive_minimum: true
    }

    refute is_valid?(schema, 1.1)
    refute is_valid?(schema, 1.2)
    assert is_valid?(schema, 1.3)
    refute is_valid?(schema, "1")

    assert validate(schema, 1.1) == {:error, %{minimum: 1.2}}
    assert validate(schema, 1.2) ==
      {:error, %{minimum: 1.2, exclusive_minimum: true}}
    assert validate(schema, 1.3) == :ok
    assert validate(schema, "1") == {:error, %{type: :float}}
  end

  test "number schema with maximum" do
    schema = Xema.create(:float, maximum: 1.2)

    assert schema.type == :float
    assert schema.properties == %Xema.Float{
      maximum: 1.2,
      exclusive_maximum: nil
    }

    assert is_valid?(schema, 1.1)
    assert is_valid?(schema, 1.2)
    refute is_valid?(schema, 1.3)
    refute is_valid?(schema, "1")

    assert validate(schema, 1.1) == :ok
    assert validate(schema, 1.2) == :ok
    assert validate(schema, 1.3) == {:error, %{maximum: 1.2}}
    assert validate(schema, "1") == {:error, %{type: :float}}
  end

  test "number schema with maximum and exclusie maximum" do
    schema = Xema.create(:float, maximum: 1.2, exclusive_maximum: true)

    assert schema.type == :float
    assert schema.properties == %Xema.Float{
      maximum: 1.2,
      exclusive_maximum: true
    }

    assert is_valid?(schema, 1.1)
    refute is_valid?(schema, 1.2)
    refute is_valid?(schema, 1.3)
    refute is_valid?(schema, "1.1")

    assert validate(schema, 1.1) == :ok
    assert validate(schema, 1.2) ==
      {:error, %{maximum: 1.2, exclusive_maximum: true}}
    assert validate(schema, 1.3) == {:error, %{maximum: 1.2}}
    assert validate(schema, "1.1") == {:error, %{type: :float}}
  end

  test "number schema with multiple of" do
    schema = Xema.create(:float, multiple_of: 1.1)

    assert schema.type == :float
    assert schema.properties == %Xema.Float{multiple_of: 1.1}

    assert is_valid?(schema, 2.2)
    refute is_valid?(schema, 3.1)
    assert is_valid?(schema, 4.4)
    refute is_valid?(schema, "4.4")

    assert validate(schema, 2.2) == :ok
    assert validate(schema, 3.1) == {:error, %{multiple_of: 1.1}}
    assert validate(schema, 31) == {:error, %{type: :float}}
    assert validate(schema, 4.4) == :ok
    assert validate(schema, "4.4") == {:error, %{type: :float}}
  end
end
