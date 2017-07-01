defmodule Xema.NumberTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  describe "number schema with integer" do
    test "number schema" do
      schema = Xema.create(:number)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{}

      assert is_valid?(schema, 1)
      assert is_valid?(schema, 1.1)
      refute is_valid?(schema, "1")
      refute is_valid?(schema, %{bla: 1})

      assert validate(schema, 1) == :ok
      assert validate(schema, 1.1) == :ok
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
      assert validate(schema, %{bla: 1}) ==
        {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with minimum" do
      schema = Xema.create(:number, minimum: 2)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{minimum: 2}

      refute is_valid?(schema, 1)
      assert is_valid?(schema, 2)
      assert is_valid?(schema, 3)
      refute is_valid?(schema, "1")

      assert validate(schema, 1) == {:error, :too_small, %{minimum: 2}}
      assert validate(schema, 2) == :ok
      assert validate(schema, 3) == :ok
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with minimum and exclusive minimum" do
      schema = Xema.create(:number, minimum: 2, exclusive_minimum: true)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{
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
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with maximum" do
      schema = Xema.create(:number, maximum: 2)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{
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
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with maximum and exclusie maximum" do
      schema = Xema.create(:number, maximum: 2, exclusive_maximum: true)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{
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
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with multiple of" do
      schema = Xema.create(:number, multiple_of: 2)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{multiple_of: 2}

      assert is_valid?(schema, 2)
      refute is_valid?(schema, 3)
      assert is_valid?(schema, 4)
      refute is_valid?(schema, "1")

      assert validate(schema, 2) == :ok
      assert validate(schema, 3) == {:error, :not_multiple, %{multiple_of: 2}}
      assert validate(schema, 4) == :ok
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end
  end

  describe "number schema with float" do
    test "number schema with minimum" do
      schema = Xema.create(:number, minimum: 1.2)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{minimum: 1.2}

      refute is_valid?(schema, 1.1)
      assert is_valid?(schema, 1.2)
      assert is_valid?(schema, 1.3)
      refute is_valid?(schema, "1")

      assert validate(schema, 1.1) == {:error, :too_small, %{minimum: 1.2}}
      assert validate(schema, 1.2) == :ok
      assert validate(schema, 1.3) == :ok
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with minimum and exclusive minimum" do
      schema = Xema.create(:number, minimum: 1.2, exclusive_minimum: true)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{
        minimum: 1.2,
        exclusive_minimum: true
      }

      refute is_valid?(schema, 1.1)
      refute is_valid?(schema, 1.2)
      assert is_valid?(schema, 1.3)
      refute is_valid?(schema, "1")

      assert validate(schema, 1.1) == {:error, :too_small, %{minimum: 1.2}}
      assert validate(schema, 1.2) ==
        {:error, :too_small, %{minimum: 1.2, exclusive_minimum: true}}
      assert validate(schema, 1.3) == :ok
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with maximum" do
      schema = Xema.create(:number, maximum: 1.2)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{
        maximum: 1.2,
        exclusive_maximum: nil
      }

      assert is_valid?(schema, 1.1)
      assert is_valid?(schema, 1.2)
      refute is_valid?(schema, 1.3)
      refute is_valid?(schema, "1")

      assert validate(schema, 1.1) == :ok
      assert validate(schema, 1.2) == :ok
      assert validate(schema, 1.3) == {:error, :too_big, %{maximum: 1.2}}
      assert validate(schema, "1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with maximum and exclusie maximum" do
      schema = Xema.create(:number, maximum: 1.2, exclusive_maximum: true)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{
        maximum: 1.2,
        exclusive_maximum: true
      }

      assert is_valid?(schema, 1.1)
      refute is_valid?(schema, 1.2)
      refute is_valid?(schema, 1.3)
      refute is_valid?(schema, "1.1")

      assert validate(schema, 1.1) == :ok
      assert validate(schema, 1.2) ==
        {:error, :too_big, %{maximum: 1.2, exclusive_maximum: true}}
      assert validate(schema, 1.3) == {:error, :too_big, %{maximum: 1.2}}
      assert validate(schema, "1.1") == {:error, :wrong_type, %{type: :number}}
    end

    test "number schema with multiple of" do
      schema = Xema.create(:number, multiple_of: 1.1)

      assert schema.type == :number
      assert schema.keywords == %Xema.Number{multiple_of: 1.1}

      assert is_valid?(schema, 2.2)
      refute is_valid?(schema, 3.1)
      assert is_valid?(schema, 4.4)
      refute is_valid?(schema, "4.4")

      assert validate(schema, 2.2) == :ok
      assert validate(schema, 3.1) == {:error, :not_multiple, %{multiple_of: 1.1}}
      assert validate(schema, 31) == {:error, :not_multiple, %{multiple_of: 1.1}}
      assert validate(schema, 4.4) == :ok
      assert validate(schema, "4.4") == {:error, :wrong_type, %{type: :number}}
    end
  end
end
