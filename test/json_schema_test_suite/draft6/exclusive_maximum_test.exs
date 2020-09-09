defmodule JsonSchemaTestSuite.Draft6.ExclusiveMaximumTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe ~s|exclusiveMaximum validation| do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"exclusiveMaximum" => 3.0},
            draft: "draft6",
            atom: :force
          )
      }
    end

    test ~s|below the exclusiveMaximum is valid|, %{schema: schema} do
      assert valid?(schema, 2.2)
    end

    test ~s|boundary point is invalid|, %{schema: schema} do
      refute valid?(schema, 3.0)
    end

    test ~s|above the exclusiveMaximum is invalid|, %{schema: schema} do
      refute valid?(schema, 3.5)
    end

    test ~s|ignores non-numbers|, %{schema: schema} do
      assert valid?(schema, "x")
    end
  end
end
