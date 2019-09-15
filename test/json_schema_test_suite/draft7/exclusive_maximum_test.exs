defmodule JsonSchemaTestSuite.Draft7.ExclusiveMaximum do
  use ExUnit.Case

  import Xema, only: [valid?: 2]

  describe "exclusiveMaximum validation" do
    setup do
      %{schema: Xema.from_json_schema(%{"exclusiveMaximum" => 3.0})}
    end

    test "below the exclusiveMaximum is valid", %{schema: schema} do
      assert valid?(schema, 2.2)
    end

    test "boundary point is invalid", %{schema: schema} do
      refute valid?(schema, 3.0)
    end

    test "above the exclusiveMaximum is invalid", %{schema: schema} do
      refute valid?(schema, 3.5)
    end

    test "ignores non-numbers", %{schema: schema} do
      assert valid?(schema, "x")
    end
  end
end
