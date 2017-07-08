defmodule Xema.NilTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  setup do
    %{
      as_nil: Xema.create(:nil),
      as_null: Xema.create(:nil, as: :null)
    }
  end

  test "type", schemas do
    assert schemas.as_nil.type == :nil
    assert Xema.type(schemas.as_nil) == :nil

    assert schemas.as_null.type == :nil
    assert Xema.type(schemas.as_null) == :null
  end

  describe "validate nil schema" do
    test "with nil", %{as_nil: schema},
      do: assert validate(schema, nil) == :ok

    test "with 1", %{as_nil: schema} do
      assert validate(schema, 1) == {:error, %{reason: :wrong_type, type: :nil}}
    end
  end

  describe "validate null schema" do
    test "with 1", %{as_null: schema} do
      expected = {:error, %{reason: :wrong_type, type: :null}}
      assert validate(schema, 1) == expected
    end
  end

  describe "check validation of null schema" do
    test "with nil", %{as_nil: schema},
      do: assert is_valid?(schema, nil)

    test "with 1", %{as_nil: schema},
      do: refute is_valid?(schema, 1)
  end
end
