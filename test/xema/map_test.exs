defmodule Xema.MapTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  alias Xema.Map

  setup do
    %{
      map: Xema.create(:map),
      object: Xema.create(:map, as: :object),
      props: Xema.create(
        :map,
        properties: %{
          foo: Xema.create(:number),
          bar: Xema.create(:string)
        })
    }
  end

  test "type and keywords", schemas do
    assert schemas.map.type == :map
    assert schemas.map.keywords == %Map{}

    assert schemas.object.type == :map
    assert schemas.object.keywords.as == :object
  end

  describe "validate/2" do
    test "with an empty map", %{map: schema},
      do: assert validate(schema, %{}) == :ok

    test "map with a string", %{map: schema} do
      expected = {:error, :wrong_type, %{type: :map}}
      assert validate(schema, "foo") == expected
    end

    test "object with a string", %{object: schema} do
      expected = {:error, :wrong_type, %{type: :object}}
      assert validate(schema, "foo") == expected
    end

    test "properties with valid values", %{props: schema},
      do: assert validate(schema, %{foo: 2, bar: "bar"}) == :ok

    test "properties with invalid values", %{props: schema} do
      expected = {
        :error,
        :invalid_property,
        %{
          property: :foo,
          error: {:error, :wrong_type, %{type: :number}}
        }
      }
      assert validate(schema, %{foo: "foo", bar: "bar"}) == expected
    end

  end

  describe "is_valid/2" do
    test "with an empty map", %{map: schema},
      do: assert is_valid?(schema, %{})

    test "map with a string", %{map: schema},
      do: refute is_valid?(schema, "foo")
  end
end
