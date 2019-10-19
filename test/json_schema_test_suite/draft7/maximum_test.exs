defmodule JsonSchemaTestSuite.Draft7.MaximumTest do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "maximum validation" do
    setup do
      %{
        schema:
          Xema.from_json_schema(
            %{"maximum" => 3.0},
            draft: "draft7"
          )
      }
    end

    test "below the maximum is valid", %{schema: schema} do
      assert valid?(schema, 2.6)
    end

    test "boundary point is valid", %{schema: schema} do
      assert valid?(schema, 3.0)
    end

    test "above the maximum is invalid", %{schema: schema} do
      refute valid?(schema, 3.5)
    end

    test "ignores non-numbers", %{schema: schema} do
      assert valid?(schema, "x")
    end
  end
end
