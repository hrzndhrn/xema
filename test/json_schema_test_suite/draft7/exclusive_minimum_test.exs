defmodule JsonSchemaTestSuite.Draft7.ExclusiveMinimumTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|exclusiveMinimum validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"exclusiveMinimum" => 1.1},
            draft: "draft7",
            atom: :force
          )
      }
    end

    test ~s|above the exclusiveMinimum is valid|, %{schema: schema} do
      assert valid?(schema, 1.2)
    end

    test ~s|boundary point is invalid|, %{schema: schema} do
      refute valid?(schema, 1.1)
    end

    test ~s|below the exclusiveMinimum is invalid|, %{schema: schema} do
      refute valid?(schema, 0.6)
    end

    test ~s|ignores non-numbers|, %{schema: schema} do
      assert valid?(schema, "x")
    end
  end
end
