defmodule Xema.Cast.DeleteTest do
  use ExUnit.Case, async: true

  import Xema, only: [cast: 3]

  alias Xema.{CastError, ValidationError}

  @opts [additionals: :delete]

  describe "cast/2 with option [additionals: :delete]" do
    setup do
      %{
        schema:
          Xema.new(
            {:map,
             properties: %{
               a: :integer,
               b: :integer
             },
             additional_properties: false}
          )
      }
    end

    test "converts the given properties", %{schema: schema} do
      assert cast(schema, %{a: "1", b: "2"}, @opts) == {:ok, %{a: 1, b: 2}}
    end

    test "deletes additional properties", %{schema: schema} do
      assert cast(schema, %{a: "1", x: "2"}, @opts) == {:ok, %{a: 1, b: 2}}
    end
  end
end
