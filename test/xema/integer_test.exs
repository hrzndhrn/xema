defmodule Xema.IntegerTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  @tag :xema_type
  test "integer schema" do
    schema = Xema.create(:integer)

    assert schema.type == :integer
    assert schema.properties == %Xema.Integer{}

    assert validate(schema, 1) == :ok
    assert is_valid?(schema, 1)
    refute is_valid?(schema, 1.1)
    refute is_valid?(schema, "1")
    refute is_valid?(schema, %{bla: 1})

    assert validate(schema, 1) == :ok
    assert validate(schema, 1.1) == {:error, :wrong_type, %{type: :integer}}
    assert validate(schema, "1") == {:error, :wrong_type, %{type: :integer}}
    assert validate(schema, %{bla: 1}) ==
      {:error, :wrong_type, %{type: :integer}}
  end

  @tag :minimum
  test "integer schema with minimum" do
    schema = Xema.create(:integer, minimum: 2)

    assert schema.type == :integer
    assert schema.properties == %Xema.Integer{minimum: 2}

    refute is_valid?(schema, 1)
    assert is_valid?(schema, 2)
    assert is_valid?(schema, 3)
    refute is_valid?(schema, "1")

    assert validate(schema, 1) == {:error, :too_small, %{minimum: 2}}
    assert validate(schema, 2) == :ok
    assert validate(schema, 3) == :ok
    assert validate(schema, "1") == {:error, :wrong_type, %{type: :integer}}
  end

  test "integer schema with minimum and exclusive minimum" do
    schema = Xema.create(:integer, minimum: 2, exclusive_minimum: true)

    assert schema.type == :integer
    assert schema.properties == %Xema.Integer{
      minimum: 2,
      exclusive_minimum: true
    }

    refute is_valid?(schema, 1)
    refute is_valid?(schema, 2)
    assert is_valid?(schema, 3)
    refute is_valid?(schema, "1")

    assert validate(schema, 1) == {:error, :too_small, %{minimum: 2}}
    assert validate(schema, 2) ==
      {:error, :too_small, %{minimum: 2, exclusive_minimum: true}}
    assert validate(schema, 3) == :ok
    assert validate(schema, "1") == {:error, :wrong_type, %{type: :integer}}
  end

  test "integer schema with maximum" do
    schema = Xema.create(:integer, maximum: 2)

    assert schema.type == :integer
    assert schema.properties == %Xema.Integer{
      maximum: 2,
      exclusive_maximum: nil
    }

    assert is_valid?(schema, 1)
    assert is_valid?(schema, 2)
    refute is_valid?(schema, 3)
    refute is_valid?(schema, "1")

    assert validate(schema, 1) == :ok
    assert validate(schema, 2) == :ok
    assert validate(schema, 3) == {:error, :too_big, %{maximum: 2}}
    assert validate(schema, "1") == {:error, :wrong_type, %{type: :integer}}
  end

  test "integer schema with maximum and exclusie maximum" do
    schema = Xema.create(:integer, maximum: 2, exclusive_maximum: true)

    assert schema.type == :integer
    assert schema.properties == %Xema.Integer{
      maximum: 2,
      exclusive_maximum: true
    }

    assert is_valid?(schema, 1)
    refute is_valid?(schema, 2)
    refute is_valid?(schema, 3)
    refute is_valid?(schema, "1")

    assert validate(schema, 1) == :ok
    assert validate(schema, 2) ==
      {:error, :too_big, %{maximum: 2, exclusive_maximum: true}}
    assert validate(schema, 3) == {:error, :too_big, %{maximum: 2}}
    assert validate(schema, "1") == {:error, :wrong_type, %{type: :integer}}
  end

  test "integer schema with multiple of" do
    schema = Xema.create(:integer, multiple_of: 2)

    assert schema.type == :integer
    assert schema.properties == %Xema.Integer{multiple_of: 2}

    assert is_valid?(schema, 2)
    refute is_valid?(schema, 3)
    assert is_valid?(schema, 4)
    refute is_valid?(schema, "1")

    assert validate(schema, 2) == :ok
    assert validate(schema, 3) == {:error, :not_multiple, %{multiple_of: 2}}
    assert validate(schema, 4) == :ok
    assert validate(schema, "1") == {:error, :wrong_type, %{type: :integer}}
  end
end
