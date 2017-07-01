defmodule Xema.MapTest do

  use ExUnit.Case, async: true

  import Xema, only: [is_valid?: 2, validate: 2]

  alias Xema.List
  alias Xema.Map

  setup do
    %{
      map: Xema.create(:map),
      object: Xema.create(:map, as: :object)
    }
  end

  test "type and properties", schemas do
    assert schemas.map.type == :map
    assert schemas.map.properties == %Map{}

    assert schemas.object.type == :map
    assert schemas.object.properties.as == :object
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
  end
end
