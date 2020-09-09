defmodule JsonSchemaTestSuite.Draft7.MinItemsTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|minItems validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"minItems" => 1},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|longer is valid|, %{schema: schema} do
      assert valid?(schema, [1, 2])
    end

    test ~s|exact length is valid|, %{schema: schema} do
      assert valid?(schema, [1])
    end

    test ~s|too short is invalid|, %{schema: schema} do
      refute valid?(schema, [])
    end

    test ~s|ignores non-arrays|, %{schema: schema} do
      assert valid?(schema, "")
    end
  end
end
